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
  
  resource_group_name   = "dunab13-rg"
  location              = "West Europe"
  vnet_name             = "dunab13-vnet"
  address_space         = ["10.6.0.0/16"]
  subnet1_name          = "db13-sbnt"
  subnet1_prefix        = ["10.6.1.0/24"]
  gateway_name          = "dunab13_gateway"
  pubIP_gateway_name    = "dunab13_gateway_pubIP"
  pubIP_allocation      = "Static"
  pubIP_sku             = "Standard"
  priv_subnet_name      = "dunab13_priv_sbnt"
  priv_sbnt_add_pref    = ["10.6.2.0/24"]
  pub_subnet_name       = "dunab13_pub_sbnt"
  pub_sbnt_add_pref     = ["10.6.3.0/24"]
  nic_publicIP_name     = "dunab13_nic_pubIP"
  nic_pubIP_allocation  = "Static"
  sku_nic_pubIP         = "Standard"
  vm_name               = "dunab13-VM"
  vm_size               = "Standard_DS1_v2"
  admin_username        = "DunaAdmin"
  storage_account_type  = "Premium_LRS"
  nic_name              = "dunab13_Nic"
  nicIP_conf            = "internal"
  nic_allocation        = "Dynamic"
}
