terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.47.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}

#   Resource group   #
######################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

#   VNet & Subnet   #
#####################
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#   Virtual Machine   #
#######################
resource "azurerm_virtual_machine" "vm" {
  name                             = var.prefix
  location                         = azurerm_resource_group.rg.location
  resource_group_name              = azurerm_resource_group.rg.name
  network_interface_ids            = [azurerm_network_interface.nic.id]
  vm_size                          = "Standard_B1s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = var.admin_username
    custom_data    = data.template_file.customdata.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = data.azurerm_ssh_public_key.ssh_public_key.public_key
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_public_ip.pip
  ]

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

data "azurerm_ssh_public_key" "ssh_public_key" {
  resource_group_name = var.ssh_key_rg
  name                = var.ssh_key_name
}

data "template_file" "customdata" {
  template = file("${abspath(path.module)}/customdata.sh")
}

# to allow an application or service to authenticate with Azure services without requiring a username or password
resource "azurerm_user_assigned_identity" "identity" {
  name                = "${var.prefix}-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}