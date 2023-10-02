<div style='text-align: justify;'>

<div id='top'/>

# Hardening of a Linux machine

## Summary

###### [00 - Daily Scrum](#Scrum)

###### [01 -  Doc reading](#Doc)

###### [02 - Creation of a resource group and deployment of the infrastructure](#RG)

###### [03 - Creating the pipeline](#Pipeline)

###### [04 - Choosing the security tests checking tools](#Choice)

###### [05 - Installation of Trivy](#Trivy)

###### [06 - Installation of OWASP Zap](#Owasp)

###### [07 - Using Trivy and OWASP Zap with Azure DevOps Pipelines](#T&OwtADP)

###### [08 - Prompting administrator to continue or not the pipeline after a failure status from tests](#Admin)

###### [09 - Definition of the different tools](#Definition)

&nbsp;&nbsp;&nbsp;[a) SonarQube](#Sonar)  
&nbsp;&nbsp;&nbsp;[b) OWASP Dependency-Check](#OWASP1)  
&nbsp;&nbsp;&nbsp;[c) Clair](#Clair)  
&nbsp;&nbsp;&nbsp;[d) Trivy](#Trivy)  
&nbsp;&nbsp;&nbsp;[e) Grype](#Grype)  
&nbsp;&nbsp;&nbsp;[f) OWASP Zap](#OWASP2)  

###### [10 - Installation of Prometheus and Grafana](#PromGraf)

###### [11 - Creation and configuration of alerts and rotation of dashboards](#Dashboards)

###### [12 - Usefull Commands](#UsefullCommands)

<div id='Scrum'/>  

### **Scrum quotidien**

Scrum Master = Me, myself and I
Daily personnal reactions with reports and designations of first tasks for the day.

Frequent meeting with other coworkers to study solutions to encountered problems together.

[scrums](https://github.com/simplon-lerouxDunvael/Brief_7/blob/main/Plans_et_demarches/Scrum.md)

[&#8679;](#top)

<div id='Docs'/>  

#### **doc reading**

Researches and reading of documentations to determine the needed prerequisites, functionnalities and softwares to complete the different tasks of Brief 10.

[&#8679;](#top)  

<div id='RG'/>  

### **Creation of a resource group and deployment of the infrastructure**

I created a resource group and deployed the infrastructure with Terraform.

Then I checked the list of rules to apply with ansible role :

R28 Partitionnement type
R30 Désactiver lex comptes utilisateurs inutilisés
R31 Utiliser des mots de passe robustes
R32 Expirer les sessions utilisateur locales
R33 Assurer l'imputabilité des actions d'amdministration
R34 Désactiver les comptes de service
R35 Utiliser des comptes de service uniques et exclusifs
R39 Modifier les directives de configuration sudo
R40 Utiliser des utilisateurs cibles non-privilégiés pour les commandes sudo
R42 Bannir les négations dans les spécifications sudo
R43 Préciser les arguments dans les spécifications sudo
R44 Editer les fichiers de manière sécurisée avec sudo
R50 Restreindre les droits d'accès aux fichiers et aux répertoires sensibles
R52 Restreindre les droits d'accès aux sockets et aux pipes nommées
R53 2viter les fichiers ou répertoires sans utilisateurs ou sans groupe connu
R54 Activer le sticky bit sur les répertoires inscriptibles
R55 Séparer les répertoires temporaires des utilisateurs
R53 Eviter l'usage d'exécutables avec les droits spéciaux setuid et setgid
R58 N'installer que les paquets strictement nécessaires
R59 Utiliser des dépôts de paquet de confiance
R61 Effectuer des mises à jour régulières
R62 Désactiver les services non nécessaires
R63 Désactiver les fonctionnalités des services non essentielles
R67 Sécuriser les authentifications distantes par PAM
R68 Protéger les mots de passe stockés
R69 Sécuriser les accès aux bases utlisateurs distantes
R70 Séparer les comptes systèmes et d'administrateur de l'annuaire
R79 Durcir et surveiller les services exposés
R80 Réduire la surface d'attaque des services réseaux

List with minimal rules only :

R30 Désactiver lex comptes utilisateurs inutilisés
R31 Utiliser des mots de passe robustes
R53 2viter les fichiers ou répertoires sans utilisateurs ou sans groupe connu
R54 Activer le sticky bit sur les répertoires inscriptibles
R56 Eviter l'usage d'exécutables avec les droits spéciaux setuid et setgid
R58 N'installer que les paquets strictement nécessaires
R59 Utiliser des dépôts de paquet de confiance
R61 Effectuer des mises à jour régulières
R62 Désactiver les services non nécessaires
R68 Protéger les mots de passe stockés
R80 Réduire la surface d'attaque des services réseaux

I also found a [redhat GitHub repo](https://github.com/RedHatOfficial/ansible-role-rhel8-anssi_bp28_enhanced/blob/master/tasks/main.yml) with all the rules in code.

[&#8679;](#top)

<div id='Pipeline'/>  

### ****


[&#8679;](#top)

<div id='Choice'/>  

### ****



[&#8679;](#top)

<div id='Trivy'/>  

### ****


[&#8679;](#top)

<div id='Owasp'/>  

### ****



[&#8679;](#top)

<div id='T&OwtADP'/>  

### ****



[&#8679;](#top)

<div id='Admin'/>  

### ****


[&#8679;](#top)

<div id='PromGraf'/>  

### **Installation of SCAP**



[&#8679;](#top)

<div id='Dashboards'/>  

### ****


[&#8679;](#top)


<div id='UsefullCommands'/>  

### **USEFULL COMMANDS**

### **To clone and pull a GitHub repository**

```bash
git clone [GitHubRepositoryURL]
```

```bash
git pull
```

[&#8679;](#top)

### **To create an alias for a command on azure CLi**

alias [WhatWeWant]="[WhatIsChanged]"  

*Example :*  

```bash
alias k="kubectl"
```

[&#8679;](#top)

### **To deploy resources with yaml file with Terrafom**

terraform init
terraform plan
tarreform apply

[&#8679;](#top)

### **To check resources**

```bash
kubectl get nodes
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get events
kubectl get secrets
kubectl get logs
helm list --all-namespaces
k get ingressclass --all-namespaces
```

*To keep verifying the resources add --watch at the end of the command :*

*Example :*

```bash
kubectl get services --watch
```

*To check the resources according to their namespace, add --namespace after the command and the namespace's name :*

*Example :*

```bash
kubectl get services --namespace [namespace's-name]
```

[&#8679;](#top)

### **To describe resources**

```bash
kubectl describe nodes
kubectl describe pods
kubectl describe services # or svc
kubectl describe deployment # or deploy
kubectl describe events
kubectl describe secrets
kubectl describe logs
```

*To specify which resource needs to be described just put the resource ID at the end of the command.*

*Example :*

```bash
kubectl describe svc redis-service
```

*To access to all the logs from all containers :*

```bash
kubectl logs podname --all-containers
```

*To access to the logs from a specific container :*

```bash
kubectl logs podname -c [container's-name]
```

*To list all events from a specific pod :*

```bash
kubectl get events --field-selector [involvedObject].name=[podsname]
```

[&#8679;](#top)

### **To delete resources**

```bash
kubectl delete deploy --all
kubectl delete svc --all
kubectl delete pvc --all
kubectl delete pv --all
kubectl delete ingress --all
kubectl delete secrets --all
kubectl delete certificates --all
az group delete --name [resourceGroupName] --yes --no-wait

kubectl delete deployments --all -n [namespaceName]
kubectl delete pods --all -n [namespaceName]
kubectl delete replicaset --all -n [namespaceName]
kubectl delete statefulset --all -n [namespaceName]
kubectl delete daemonset --all -n [namespaceName]
kubectl delete svc --all -n [namespaceName]
kubectl delete namespace [namespaceName]
kubectl delete clusterrole prometheus-grafana-clusterrole
kubectl delete clusterrole prometheus-kube-state-metrics
kubectl delete clusterrole system:prometheus
kubectl delete clusterrolebinding --all -n [namespaceName]
k delete ingressclass [insert ingressclass] --all-namespaces
```

[&#8679;](#top)

### **To check TLS certificate in request order**

```bash
kubectl get certificate
kubectl get certificaterequest
kubectl get order
kubectl get challenge
```

[&#8679;](#top)

### **To describe TLS certificate in request order**

```bash
kubectl describe certificate
kubectl describe certificaterequest
kubectl describe order
kubectl describe challenge
```

[&#8679;](#top)

### **Get the IP address to point the DNS to nginx in the two namespaces**

```bash
kubectl get svc --all-namespaces
```

[&#8679;](#top)

</div>