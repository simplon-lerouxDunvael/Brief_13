# Variables pour le déploiement du module avec les ressources et le cluster AKS

# Variable localisation et RG

variable resource_group_name {
  description = "Nom du RG"
  type = string
  default = "db13-rg"
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
  default = "db13-vnet"
}

variable address_space {
  description = "CIDR"
  type = list(string)
  default = ["10.6.0.0/16"]
}

variable subnet1_name {
  description = "Nom du sous-réseau 1"
  type = string
  default = "db13-sbnt"
}

variable subnet1_prefix {  
  description = "Plage d'adresses IP pour le sous-réseau 1"
  type = list(string)
  default = ["10.6.1.0/24"]
}

variable gateway_name {  
  description = "Nom de la passerelle"
  type = string
  default = "db13_gateway"
}

variable pubIP_gateway_name {  
  description = "Nom de l'IP publique de la gateway"
  type = string
  default = "db13_gateway_pubIP"
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

variable priv_subnet_name {  
  description = "Nom du sous-réseau privé"
  type = string
  default = "db13_priv_sbnt"
}

variable priv_sbnt_add_pref {  
  description = "Plage d'adresses IP pour le sous-réseau privé"
  type = list(string)
  default = ["10.6.2.0/24"]
}

variable pub_subnet_name {  
  description = "Nom du sous-réseau publique"
  type = string
  default = "db13_pub_sbnt"
}

variable pub_sbnt_add_pref {  
  description = "Plage d'adresses IP pour le sous-réseau publique"
  type = list(string)
  default = ["10.6.3.0/24"]
}

# Variables pour la VM

variable vm_name {
  description = "Nom du cluster AKS"
  type = string
  default = "db13-VM"
}

variable vm_size {
  description = "Taille de la VM"
  type = string
  default = "Standard_D2_v2"
}

variable admin_username {
  description = "Nom de l'administrateur de la VM"
  type = string
  default = "DunaAdmin"
}

variable sshkey_username {
  description = "Nom de l'utilisateur SSH"
  type = string
  default = "DunaKeys"
}

variable storage_account_type {
  description = "Type de compte de stockage"
  type = string
  default = "Premium_LRS"
}

variable nic_name {
  description = "Nom du NIC"
  type = string
  default = "b13_Nic"
}

variable nicIP_conf {
  description = "Nom de la configuration NIC"
  type = string
  default = "internal"
}

variable nic_allocation {
  description = "Type d'allocation de l'adresse IP privée"
  type = string
  default = "Dynamic"
}