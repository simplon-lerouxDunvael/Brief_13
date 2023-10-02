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

# Déploiement du cluster AKS
resource "azurerm_kubernetes_cluster" "AKS" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  
  default_node_pool {
    name               = var.node_pool_name
    node_count         = var.node_count
    vm_size            = var.vm_size
    vnet_subnet_id     = azurerm_subnet.subnet1.id 
  }

  /* network_profile {
    network_plugin     = "kubenet"
    load_balancer_sku  = var.LB
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    pod_cidr           = var.pod_cidr
    docker_bridge_cidr = var.docker_bridge_cidr
  } */

  identity {
    type = "SystemAssigned" # UserAssigned
  }

  /* depends_on = [
    azurerm_route.routeTab,
    azurerm_role_assignment.route-association
  ] */

  tags = {
    Environment = "dev"
  }
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

/* # Créer une Route Table
resource "azurerm_route_table" "routeTab" {
  name                = var.routeTab_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Attacher la Route Table au Subnet
resource "azurerm_subnet_route_table_association" "route-association" {
  subnet_id      = azurerm_subnet.subnet1.id
  route_table_id = azurerm_route_table.routeTab.id
} */

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
