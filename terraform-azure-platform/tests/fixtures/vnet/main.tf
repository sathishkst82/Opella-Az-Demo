resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

resource "azurerm_resource_group" "this" {
  name     = "rg-sathish-test-${random_string.suffix.result}"
  location = var.location
  tags = {
    Environment = "TEST"
    Project     = "sathish"
    ManagedBy   = "Terratest"
    Owner       = "platform-engineering"
    CostCenter  = "cc-platform"
    Region      = var.location
    Application = "vnet-module-test"
  }
}

module "vnet" {
  source = "../../../modules/vnet"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_name           = "vnet-sathish-test-${random_string.suffix.result}"
  address_space       = ["10.250.0.0/16"]
  tags                = azurerm_resource_group.this.tags

  subnets = {
    management = {
      name             = "management-subnet"
      address_prefixes = ["10.250.0.0/24"]
    }
    application = {
      name              = "application-subnet"
      address_prefixes  = ["10.250.10.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
  }
}
