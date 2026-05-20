locals {
  name_prefix = "${var.project}-${var.environment}-${var.location}"
  compact     = "${var.project}${var.environment}${var.location_short}"

  names = {
    resource_group     = "rg-${local.name_prefix}"
    vnet               = "vnet-${local.name_prefix}"
    vm                 = "vm-${local.name_prefix}-001"
    storage            = substr("st${local.compact}001", 0, 24)
    log_analytics      = "law-${local.name_prefix}"
    private_dns_blob   = "privatelink.blob.core.windows.net"
    route_table_egress = "rt-${local.name_prefix}-egress"
  }

  common_tags = merge({
    Environment = upper(var.environment)
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Region      = var.location
    Application = var.application
  })

  vnet_cidr = "10.15.0.0/16"

  subnets = {
    management = {
      name             = "management-subnet"
      address_prefixes = ["10.15.0.0/24"]
      nsg_rules        = ["allow-rdp-private"]
      route_table      = local.names.route_table_egress
    }
    application = {
      name              = "application-subnet"
      address_prefixes  = ["10.15.10.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      route_table       = local.names.route_table_egress
    }
    data = {
      name              = "data-subnet"
      address_prefixes  = ["10.15.20.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      route_table       = local.names.route_table_egress
    }
    private_endpoint = {
      name                                          = "private-endpoint-subnet"
      address_prefixes                              = ["10.15.30.0/24"]
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
      create_nsg                                    = false
    }
    future_reserved = {
      name             = "future-reserved-subnet"
      address_prefixes = ["10.15.250.0/24"]
    }
  }
}

resource "azurerm_resource_group" "this" {
  name     = local.names.resource_group
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastPatchedBy"]]
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.names.log_analytics
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = 60
  tags                = local.common_tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = local.names.private_dns_blob
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.common_tags
}

module "network" {
  source = "../../modules/vnet"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_name           = local.names.vnet
  address_space       = [local.vnet_cidr]
  subnets             = local.subnets
  enable_ddos         = false
  tags                = local.common_tags

  nsg_rules = {
    management = [{
      name                       = "allow-rdp-private"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
      description                = "RDP only from private enterprise address space."
    }]
  }

  route_tables = {
    (local.names.route_table_egress) = {
      routes = [{
        name           = "default-internet-egress"
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }]
    }
  }

  private_dns_links = {
    (azurerm_private_dns_zone.blob.name) = {
      resource_group_name = azurerm_resource_group.this.name
    }
  }
}

module "storage" {
  source = "../../modules/storage"

  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  storage_account_name     = local.names.storage
  account_replication_type = "LRS"
  tags                     = local.common_tags

  containers = {
    artifacts = { name = "artifacts" }
    logs      = { name = "logs" }
    rag       = { name = "rag-knowledge" }
  }

  network_rules = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [module.network.subnet_ids.application, module.network.subnet_ids.data]
  }

  private_endpoint = {
    enabled             = true
    subnet_id           = module.network.subnet_ids.private_endpoint
    private_dns_zone_id = azurerm_private_dns_zone.blob.id
  }

  lifecycle_rules = {
    logs-retention = {
      prefix_match = ["logs/"]
      base_blob = {
        tier_to_cool_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than       = 180
      }
    }
  }
}

module "vm" {
  source = "../../modules/vm"

  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  boot_diagnostics_storage_uri = module.storage.primary_blob_endpoint
  tags                         = local.common_tags

  vms = {
    ops = {
      name           = local.names.vm
      computer_name  = "opluatops001"
      size           = "Standard_B2ms"
      subnet_id      = module.network.subnet_ids.management
      admin_username = var.admin_username
      admin_password = var.admin_password
      data_disks = {
        tools = {
          lun          = 0
          disk_size_gb = 64
        }
      }
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_blob" {
  name                       = "diag-${local.names.storage}-blob"
  target_resource_id         = "${module.storage.storage_account_id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }
}

module "governance" {
  source = "../../modules/governance"

  assignment_scope  = azurerm_resource_group.this.id
  allowed_locations = var.allowed_locations
  required_tags     = ["Environment", "Project", "ManagedBy", "Owner", "CostCenter", "Region", "Application"]
  enforcement_mode  = "DoNotEnforce"
}
