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

Then I added the VM and the variables in my main.tf terraform module (in Brief_13_bis). I modified the variables in the main.tf (in Brief_13).
I used the following commands to deploy my infra :

```Bash
terraform init -upgrade
terraform plan
terrafor apply
```

Then I had an issue with the storage account type and the vm size with the osDisk that did not work together. I had to change to `DS1_V2` to be able to use `Premium_LRS` storage account.

Then I had an issue with the ssh keys that could not be found. I found the solution on this [publication](https://discuss.hashicorp.com/t/azure-provider-ssh-public-keys-destination-path-restriction/40909/3).

[&#8679;](#top)

<div id='Pipeline'/>  

### **Inventory.ini and playbook.yml**

#### Inventory

The Ansible inventory.ini file is a file that lists the hosts on which to run Ansible tasks or playbooks. It is used to define the targets on which Ansible will act.

It identifies target machines, their IP addresses or hostnames, and the groups to which they belong. It organizes the hosts into logical groups to simplify management by organizing hosts according to role (e.g. web servers, databases) or location (e.g. data center A, data center B), and run specific playbooks on groups of hosts.

To reference an Azure virtual machine in an Ansible inventory file (inventory.ini), it is possible to use either the virtual machine's public IP address or its host name.

To create an inventory.ini file with IP address :

```Bash
[azure_vms]
azure_vm ansible_host=<adresse_IP_publique>
```

* [azure_vms] is the name of the inventory group to reference in the Ansible playbooks
* azure_vm is the name assigned to the virtual machine
* <public_IP_address> must be replaced by the public IP address of the Azure virtual machine

To create an inventory.ini file with the host name :

* [azure_vms] is the name of the inventory group to reference in the Ansible playbooks
* azure_vm is the name assigned to the virtual machine
* <host_name> must be replaced by the host name of the Azure virtual machine

```Bash
[azure_vms]
azure_vm ansible_host=<nom_d_hote>
```

I chose to use the host name as the VM is deployed at the same time as the ansible role.

```Bash
[azure_vms]
db13-VM ansible_host=db13-VM
```

This configuration specifies that "db13-VM" is the host name, and that i want Ansible to use it as the identifier for my Azure VM.

It is also possible to use an inventory.yml file. It makes possible to create a dynamic inventory :

```Bash
# Dynamic inventory

plugin: azure_rm
# Use the default authentication method
auth_source: auto

include_vm_resource_groups:
# Include the resource group containing the VM
  - 'db13-rg'

conditionnal_groups:
# Conditionally group VMs based on computer name
  generatedVm: "'db13-VM' in computer_name"
```

*auth_source* : The auth_source variable specifies the source of the Azure credentials. It is important to ensure that the authentication source is correctly configured in the Ansible configuration or environment variables. Typically, it should be set to "auto" to use the default authentication methods.

*include_vm_resource_groups* : This section specifies which Azure resource groups to include in the inventory. It makes possible to target a specific resource group and its resources. Be careful with permissions to access these resources.

*conditionnal_groups* : The conditionnal_groups section checks if the VM's computer_name includes the string 'db13-VM'. This should work if the VM's computer name is indeed 'db13-VM'.

#### Playbook

The playbook.yml file will contain tasks and instructions for performing the audit using the oscap tool, as well as for saving the audit report. It will also run the ansible roles that are in my Github repository.

```Bash
---
- name: Run roles and SCAP audit
  hosts: db13-VM
  remote_user: DunaAdmin
  become: true
  roles:
    - "sudo"
    - ...
  tasks:
    - name: Install SCAP
      command: "sudo yum install scap-security-guide openscap-scanner"
      ignore_errors: yes

    - name: Run SCAP audit
      command: "oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_anssi_bp28_minimal system"
      register: audit_result
      ignore_errors: yes

    - name: Save audit report
      copy:
        content: "{{ audit_result.stdout }}"
        dest: ../audit_reports/audit_report.xml
      when: audit_result.rc == 0
```

I modified the playbook so it uses the db13-VM as the target host to run the SCAP audit with the specified profile.

When I run my playbook, it targets the VM named "db13-VM" using the host name I specified in the inventory file and executes the SCAP audit with the specified profile. The audit report are saved in the audit_reports directory of my GitHub repository.

To run the playbook I need to use this command :

```Bash
ansible-playbook playbook.yml -i inventory.ini
```

[&#8679;](#top)

<div id='Choice'/>  

### **Install SCAP**

*I used the playbook to install SCAP and run a scan. CF. Previous chapter.*

I searched for docs and found this [guide](https://www.open-scap.org/getting-started/).

Install and configure SCAP :

SCAP Security Guide et l'outil OpenSCAP installation :

```Bash
sudo yum install scap-security-guide openscap-scanner
```

ANSSI profile :

`Title: ANSSI-BP-028 (minimal)`
`                Id: xccdf_org.ssgproject.content_profile_anssi_bp28_minimal`

To audit my VM : *the ANSSI-PROFILE1 has to be replaced with the id of the profile.*

```Bash
sudo oscap xccdf eval --profile [ANSSI-PROFILE1] system
```

This command analyzes the system against the ANSSI security profile and generates an audit report in XML format.

To check the results the generated audit report should be examined to identify any deviations or violations of security recommendations.

If deviations are identified, action must be taken to correct them in line with ANSSI recommendations. This may involve configuration changes, patching, etc.

Once the necessary changes have been made, the audit should be re-run using the same oscap command to confirm that the hardening measures are now in place :

```Bash
sudo oscap xccdf eval --profile [ANSSI-PROFILE1] system
```

After installing SCAP on my VM, I created a playbook.yml file. In this playbook, I specify the steps required to run the SCAP audit and save the audit report. I customize `target_hosts` with the host group I want to audit, and adjust the destination path to save the audit report.

Once I've created this playbook, I run it from the command line with the following Ansible command:

```bash
ansible-playbook playbook.yml -i inventory.ini
```

This runs the audit according to my schedule or when triggered manually, saves the audit report and allows me to monitor the results.



[&#8679;](#top)

<div id='Trivy'/>  

### **Roles**

In order to create the ansible roles I used this [github repository](https://github.com/GSA/ansible-os-rhel8/tree/main) and this [ansible galaxy role](https://galaxy.ansible.com/ui/standalone/roles/RedHatOfficial/rhel8_anssi_bp28_minimal/).

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