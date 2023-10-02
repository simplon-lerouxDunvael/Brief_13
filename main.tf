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
  source = "git::https://github.com/simplon-lerouxDunvael/Brief_12Bis"
  
  resource_group_name = "db12-rg"
  location            = "francecentral"
  vnet_name           = "db12-vnet"
  address_space       = ["10.6.0.0/16"]
  subnet1_name        = "db12-sbnt"
  subnet1_prefix      = ["10.6.1.0/24"]
  gateway_name        = "db12_gateway"
  pubIP_gateway_name  = "db12_gateway_pubIP"
  pubIP_allocation    = "Static"
  pubIP_sku           = "Standard"
  /* routeTab_name       = "db12_routeTab" */
  priv_subnet_name    = "db12_priv_sbnt"
  priv_sbnt_add_pref  = ["10.6.2.0/24"]
  pub_subnet_name     = "db12_pub_sbnt"
  pub_sbnt_add_pref   = ["10.6.3.0/24"]
  aks_name            = "db12-AKS"
  dns_prefix          = "aks-db12"
  node_pool_name      = "db12pool"
  node_count          = 2
  vm_size             = "Standard_D2_v2"
}
