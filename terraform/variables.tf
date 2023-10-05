# Définition des variables pour le déploiement du main (VM, NIC, NIC pubIP)

# Variables ressources

variable subnet1_name {
  description = "Nom du sous-réseau 1"
  type = string
  default = "dunab13-sbnt"
}

variable subnet1_prefix {  
  description = "Plage d'adresses IP pour le sous-réseau 1"
  type = list(string)
  default = ["10.6.1.0/24"]
}

# Variables pour la VM

variable nic_publicIP_name {
  description = "Nom de l'IP publique du NIC de la VM"
  type = string
  default = "dunab13_nic_pubIP"
}

variable nic_pubIP_allocation {
  description = "Méthode d'allocation pour l'IP publique du NIC de la VM"
  type = string
  default = "Static"
}

variable sku_nic_pubIP {
  description = "SKU de l'adresse IP publique du NIC de la VM"
  type = string
  default = "Standard"
}

variable vm_name {
  description = "Nom du cluster AKS"
  type = string
  default = "dunab13-VM"
}

variable vm_size {
  description = "Taille de la VM"
  type = string
  default = "Standard_DS1_v2"
}

variable admin_username {
  description = "Nom de l'administrateur de la VM"
  type = string
  default = "DunaAdmin"
}

variable storage_account_type {
  description = "Type de compte de stockage"
  type = string
  default = "Premium_LRS"
}

variable nic_name {
  description = "Nom du NIC"
  type = string
  default = "dunab13_Nic"
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