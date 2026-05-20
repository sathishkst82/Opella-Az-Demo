locals {
  tags = merge(var.tags, {
    Module = "vm"
  })

  data_disks = {
    for item in flatten([
      for vm_key, vm in var.vms : [
        for disk_key, disk in vm.data_disks : merge(disk, {
          vm_key   = vm_key
          disk_key = disk_key
          vm_name  = vm.name
          zone     = vm.zone
        })
      ]
    ]) : "${item.vm_key}--${item.disk_key}" => item
  }
}

resource "azurerm_public_ip" "this" {
  for_each = {
    for key, vm in var.vms : key => vm
    if vm.enable_public_ip
  }

  name                = "pip-${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = each.value.zone == null ? null : [each.value.zone]
  tags                = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface" "this" {
  for_each = var.vms

  name                = "nic-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig-001"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address            = try(each.value.private_ip_address, null)
    public_ip_address_id          = try(azurerm_public_ip.this[each.key].id, null)
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["LastPatchedBy"]]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  for_each = var.vms

  name                  = each.value.name
  computer_name         = coalesce(each.value.computer_name, substr(replace(each.value.name, "-", ""), 0, 15))
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_password        = each.value.admin_password
  network_interface_ids = [azurerm_network_interface.this[each.key].id]
  zone                  = each.value.zone
  tags                  = local.tags

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
    disk_size_gb         = each.value.os_disk.disk_size_gb
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_uri
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastPatchedBy"]]
  }
}

resource "azurerm_managed_disk" "data" {
  for_each = local.data_disks

  name                 = "disk-${each.value.vm_name}-${each.value.disk_key}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
  zone                 = each.value.zone
  tags                 = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = azurerm_managed_disk.data

  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_windows_virtual_machine.this[local.data_disks[each.key].vm_key].id
  lun                = local.data_disks[each.key].lun
  caching            = local.data_disks[each.key].caching
}
