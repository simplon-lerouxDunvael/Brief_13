# Fichier faisant appel aux modules et qui déploie le cluster AKS

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

# Utilisation du module
module "deployment" {
  source = "git::https://github.com/simplon-lerouxDunvael/Brief_13_bis"
  
  resource_group_name   = "db13-rg"
  location              = "francecentral"
  vnet_name             = "db13-vnet"
  address_space         = ["10.6.0.0/16"]
  subnet1_name          = "db13-sbnt"
  subnet1_prefix        = ["10.6.1.0/24"]
  gateway_name          = "db13_gateway"
  pubIP_gateway_name    = "db13_gateway_pubIP"
  pubIP_allocation      = "Static"
  pubIP_sku             = "Standard"
  priv_subnet_name      = "db13_priv_sbnt"
  priv_sbnt_add_pref    = ["10.6.2.0/24"]
  pub_subnet_name       = "db13_pub_sbnt"
  pub_sbnt_add_pref     = ["10.6.3.0/24"]
  vm_name               = "db13-VM"
  vm_size               = "Standard_DS1_v2"
  admin_username        = "DunaAdmin"
  storage_account_type  = "Premium_LRS"
  nic_name              = "b13_Nic"
  nicIP_conf            = "internal"
  nic_allocation        = "Dynamic"
}
