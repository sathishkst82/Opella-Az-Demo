resource "azurerm_public_ip" "this" {
  for_each            = { for k, v in var.vms : k => v if v.enable_public_ip }
  name                = "pip-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  for_each            = var.vms
  name                = "nic-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = try(azurerm_public_ip.this[each.key].id, null)
  }
  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each                        = var.vms
  name                            = each.key
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this[each.key].id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  identity { type = "SystemAssigned" }

  os_disk { caching = "ReadWrite" storage_account_type = "Standard_LRS" }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  boot_diagnostics { storage_account_uri = var.boot_diagnostics_storage_uri }
  tags = var.tags
}
