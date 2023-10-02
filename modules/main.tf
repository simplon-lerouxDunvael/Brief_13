# Module de déploiement d'un RG, réseau et sous-réseau et d'un cluster AKS => https://github.com/edalferes/terraform-azure-aks/blob/master/variables.tf

terraform {
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet1_prefix
}

# BONUS

# Créer une NAT Gateway
resource "azurerm_nat_gateway" "gateway" {
  name                    = var.gateway_name
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
}

# Créer une IP publique pour la NAT Gateway
resource "azurerm_public_ip" "pubIP_gateway" {
  name                = var.pubIP_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = var.pubIP_allocation
  sku                 = var.pubIP_sku
}

# Créer un sous-réseau privé
resource "azurerm_subnet" "priv_subnet" {
  name                 = var.priv_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.priv_sbnt_add_pref
}

# Créer un sous-réseau public
resource "azurerm_subnet" "pub_subnet" {
  name                 = var.pub_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.pub_sbnt_add_pref
}


# Créez une clé SSH pour la machine virtuelle
resource "tls_private_key" "sshKey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Créez la machine virtuelle Azure
resource "azurerm_linux_virtual_machine" "example" {
  name                = var.vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.Nic.id]
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_ssh_key {
    username   = "DunaKeys"
    public_key = tls_private_key.sshKey.public_key_openssh
  }
  os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    storage_account_type = var.storage_account_type
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "8.8.2023081717"
  }
  /* provisioner "local-exec" {
  command = "ansible-galaxy install -r requirements.txt"
} */
}

# Créez une interface réseau pour la machine virtuelle
resource "azurerm_network_interface" "Nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = var.nicIP_conf
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = var.nic_allocation
  }
}