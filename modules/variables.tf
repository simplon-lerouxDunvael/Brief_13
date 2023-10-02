# Variables pour le déploiement du module avec les ressources et le cluster AKS

# Variable localisation et RG

variable resource_group_name {
  description = "Nom du RG"
  type = string
  default = "db12-rg"
}

variable location {
  description = "Localisation des ressources"
  type = string
  default = "francecentral"
}

# Variables ressources

variable vnet_name {
  description = "Nom du Vnet"
  type = string
  default = "db12-vnet"
}

variable address_space {
  description = "CIDR"
  type = list(string)
  default = ["10.6.0.0/16"]
}

variable subnet1_name {
  description = "Nom du sous-réseau 1"
  type = string
  default = "db12-sbnt"
}

variable subnet1_prefix {  
  description = "Plage d'adresses IP pour le sous-réseau 1"
  type = list(string)
  default = ["10.6.1.0/24"]
}

variable gateway_name {  
  description = "Nom de la passerelle"
  type = string
  default = "db12_gateway"
}

variable pubIP_gateway_name {  
  description = "Nom de l'IP publique de la gateway"
  type = string
  default = "db12_gateway_pubIP"
}

variable pubIP_allocation {  
  description = "Méthode d'allocation pour l'IP publique de la gateway"
  type = string
  default = "Static"
}

variable pubIP_sku {  
  description = "SKU de l'IP publique de la gateway"
  type = string
  default = "Standard"
}

/* variable routeTab_name {  
  description = "Nom de la table de routage"
  type = string
  default = "db12_routeTab"
} */

variable priv_subnet_name {  
  description = "Nom du sous-réseau privé"
  type = string
  default = "db12_priv_sbnt"
}

variable priv_sbnt_add_pref {  
  description = "Plage d'adresses IP pour le sous-réseau privé"
  type = list(string)
  default = ["10.6.2.0/24"]
}

variable pub_subnet_name {  
  description = "Nom du sous-réseau publique"
  type = string
  default = "db12_pub_sbnt"
}

variable pub_sbnt_add_pref {  
  description = "Plage d'adresses IP pour le sous-réseau publique"
  type = list(string)
  default = ["10.6.3.0/24"]
}

# Variables pour l'AKS

variable aks_name {
  description = "Nom du cluster AKS"
  type = string
  default = "db12-AKS"
}

variable dns_prefix {
  description = "DNS pour le cluster AKS"
  type = string
  default = "aks-db12"
}

variable node_pool_name {
  description = "Nom du node pool"
  type = string
  default = "db12pool"
}

variable node_count {
  description = "Nombre de nodes"
  type = number
  default = 2
}

variable vm_size {
  description = "Taille de la VM"
  type = string
  default = "Standard_D2_v2"
}

/* variable LB {
  description = "Sku du load balancer"
  type = string
  default = "standard"
}

variable "service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service.Changing this forces a new resource to be created."
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns)."
  type        = string
  default     = "10.0.0.10"
}

variable "pod_cidr" {
  description = "(Optional) The CIDR to use for pod IP addresses. Changing this forces a new resource to be created."
  type        = string
  default     = "10.244.0.0/16"
}

variable "docker_bridge_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = "172.17.0.1/16"
} */