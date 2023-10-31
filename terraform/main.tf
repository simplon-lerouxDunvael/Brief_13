# Fichier faisant appel aux modules et qui déploie la VM, le NIC et son IP public ainsi que le lien NSG/NIC

terraform {
 required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Utilisation du module
module "deployment" {
  source = "git::https://github.com/simplon-lerouxDunvael/Brief_13_bis"
  
  resource_group_name                 = "dunb13-rg"
  location                            = "francecentral"
  vnet_name                           = "dunb13-vnet"
  address_space                       = ["10.6.0.0/16"]
  pub_subnet_name                     = "dunb13_pub_sbnt"
  pub_sbnt_add_pref                   = ["10.6.3.0/24"]
  nsg_name                            = "dunb13_nsg"
  nsg-rule_name                       = "nsgRule_allow-ssh"
  nsgRule_priority                    = 1001
  nsgRule_direction                   = "Inbound"
  nsgRule_access                      = "Allow"
  nsgRule_protocol                    = "Tcp"
  nsgRule_source_port_range           = "*"
  nsgRule_destination_port_range      = "22"
  nsgRule_source_address_prefix       = "*"
  nsgRule_destination_address_prefix  = "*"
  nsg-rule_name2                      = "nsgRule_allow-outbound"
  nsgRule_priority2                   = 2001
  nsgRule_direction2                  = "Outbound"
  nsgRule_access2                     = "Allow"
  nsgRule_protocol2                   = "Tcp"
  nsgRule_source_port_range2          = "*"
  nsgRule_destination_port_range2     = "*"
  nsgRule_source_address_prefix2      = "*"
  nsgRule_destination_address_prefix2 = "*"
  /* gateway_name                        = "dunb13_gateway"
  pubIP_gateway_name                  = "dunb13_gateway_pubIP"
  pubIP_allocation                    = "Static"
  pubIP_sku                           = "Standard"
  priv_subnet_name                    = "dunb13_priv_sbnt"
  priv_sbnt_add_pref                  = ["10.6.2.0/24"]
  subnet1_name                        = "dunb13-sbnt"
  subnet1_prefix                      = ["10.6.1.0/24"]
  nic_publicIP_name                   = "dunb13_nic_pubIP"
  nic_pubIP_allocation                = "Static"
  sku_nic_pubIP                       = "Standard"
  vm_name                             = "dunb13-VM"
  vm_size                             = "Standard_DS1_v2"
  admin_username                      = "DunAdmin"
  storage_account_type                = "Premium_LRS"
  nic_name                            = "dunb13_Nic"
  nicIP_conf                          = "internal"
  nic_allocation                      = "Dynamic" */
}

# Créer une adresse IP publique pour le NIC de la VM
resource "azurerm_public_ip" "nic_public_ip" {
  name                = var.nic_publicIP_name
  resource_group_name = module.deployment.resource_group.name
  location            = module.deployment.resource_group.location
  allocation_method   = var.nic_pubIP_allocation # Use "Static" if a static IP is needed
  sku                 = var.sku_nic_pubIP
}

# Créez une interface réseau pour la machine virtuelle
resource "azurerm_network_interface" "Nic" {
  name                = var.nic_name
  location            = module.deployment.resource_group.location
  resource_group_name = module.deployment.resource_group.name

  ip_configuration {
    name                          = var.nicIP_conf
    subnet_id                     = module.deployment.subnet.id
    private_ip_address_allocation = var.nic_allocation
    public_ip_address_id          = azurerm_public_ip.nic_public_ip.id
  }
}

# Associate security group with network interface
resource "azurerm_network_interface_security_group_association" "nsgAssociation" {
  network_interface_id      = azurerm_network_interface.Nic.id
  network_security_group_id = module.deployment.nsg.id
}

# Créez la machine virtuelle Azure
resource "azurerm_linux_virtual_machine" "VM" {
  name                = var.vm_name
  /* depends_on = [local_file.inventory_rendered] */
  location            = module.deployment.resource_group.location
  resource_group_name = module.deployment.resource_group.name
  network_interface_ids = [azurerm_network_interface.Nic.id]
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/Brief_13/.ssh/id_rsa.pub")
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
  provisioner "local-exec" {
  command = "ansible-galaxy install -r ./ansible/requirements.yml"
  }
  provisioner "local-exec" {
  command = "ansible-playbook ./ansible/playbook.yml -i ./ansible/azure_rm.yml"
  }
}

