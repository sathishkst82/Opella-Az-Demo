locals {
  env       = "dev"
  cidr      = "10.10.0.0/16"
  rg_name   = "rg-opella-dev-eastus"
  vnet_name = "vnet-opella-dev-eastus"
  common_tags = {
    Environment = upper(local.env)
    Project     = var.project
    ManagedBy   = "Terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Region      = var.location
    Application = "opella-platform"
  }
}
resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.location
  tags     = local.common_tags
}
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vnet_name           = local.vnet_name
  address_space       = [local.cidr]
  subnets = {
    management-subnet       = { address_prefixes = ["10.10.1.0/24"] }
    application-subnet      = { address_prefixes = ["10.10.2.0/24"] }
    data-subnet             = { address_prefixes = ["10.10.3.0/24"] }
    private-endpoint-subnet = { address_prefixes = ["10.10.4.0/24"] }
    future-reserved-subnet  = { address_prefixes = ["10.10.5.0/24"] }
  }
  tags = local.common_tags
}
module "storage" {
  source               = "../../modules/storage"
  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  storage_account_name = "stopelladeveus001"
  containers           = ["tfstate", "artifacts", "logs"]
  tags                 = local.common_tags
}
module "vm" {
  source                       = "../../modules/vm"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = var.location
  admin_username               = "azureuser"
  admin_password               = var.admin_password
  boot_diagnostics_storage_uri = module.storage.endpoints
  vms = {
    "vm-opella-dev-eastus-001" = {
      subnet_id        = module.vnet.subnet_ids["management-subnet"]
      vm_size          = "Standard_B2ms"
      enable_public_ip = false
      computer_name    = "opldev001"
    }
  }
  tags = local.common_tags
}
module "governance" {
  source            = "../../modules/governance"
  resource_group_id = azurerm_resource_group.this.id
  location          = var.location
}
