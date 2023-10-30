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

To bound the NSG and the NIC I followed this [guide](https://www.patrickkoch.dev/posts/post_25/) and created an association resource to bound the NSG and NIC.

```Bash
# Associate security group with network interface
resource "azurerm_network_interface_security_group_association" "nsgAssociation" {
  network_interface_id      = azurerm_network_interface.Nic.id
  network_security_group_id = module.deployment.nsg.id
}
```

I also added the ansible provider (cf. doc [ansible provider](https://registry.terraform.io/providers/ansible/ansible/latest/docs)).

I use a terraform module and also deploy resources directly in my main.tf. I reference resources from the module with `module.NameOfModule.OutputName.valueIwant`.

Example : 

```Bash
# Créer une adresse IP publique pour le NIC de la VM
resource "azurerm_public_ip" "nic_public_ip" {
  name                = var.nic_publicIP_name
  resource_group_name = module.deployment.resource_group.name
  location            = module.deployment.resource_group.location
  allocation_method   = var.nic_pubIP_allocation # Use "Static" if a static IP is needed
  sku                 = var.sku_nic_pubIP
}
```

[&#8679;](#top)

<div id='Pipeline'/>  

### **Inventory.ini/yml and playbook.yml**

#### Inventory

The Ansible inventory.ini file is a file that lists the hosts on which to run Ansible tasks or playbooks. It is used to define the targets on which Ansible will act.

It identifies target machines, their IP addresses or hostnames, and the groups to which they belong. It organizes the hosts into logical groups to simplify management by organizing hosts according to role (e.g. web servers, databases) or location (e.g. data center A, data center B), and run specific playbooks on groups of hosts.

To reference an Azure virtual machine in an Ansible inventory file (inventory.ini), it is possible to use either the virtual machine's public IP address or its host name.

To create an inventory.ini file with IP address :

```Bash
[azure_vms]
azure_vm ansible_ssh_host=<adresse_IP_publique>
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
azure_vm ansible_ssh_host=<nom_d_hote>
```

I chose to use the host name as the VM is deployed at the same time as the ansible role.

```Bash
[azure_vms]
db13-VM ansible_ssh_host=db13-VM
```

This configuration specifies that "db13-VM" is the host name, and that i want Ansible to use it as the identifier for my Azure VM.

It is also possible to use an inventory.yml file (the file name must finish by azure_rm.yml to work). It makes possible to create a dynamic inventory :

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

I checked these docs to create a dynamic inventory :

* [azure doc](https://learn.microsoft.com/en-us/azure/developer/ansible/dynamic-inventory-configure?tabs=azure-cli)
* [ansible doc1](https://docs.ansible.com/ansible/latest/collections/azure/azcollection/azure_rm_inventory.html)
* [ansible doc2](https://galaxy.ansible.com/ui/repo/published/azure/azcollection/)

Attention : to be able to use the dynamic inventory it is necessary to install the plugin `azure_rm`. I can do it manually with the command `ansible-galaxy collection install my_namespace.my_collection` or i can install the plugin as a `dependance` in the `requirements.yml` file.

I checked this [requirements ansible doc](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html#install-multiple-collections-with-a-requirements-file) to be able to do it.

The plugins for ansible are hosted in ansible-galaxy. Each plugin has a provider and a collection name. For example, for `azure_rm plugin`, the provider (or namespace) is `azure` and the collection is `azcollection`. The type of the collection is `galaxy` as it is hosted in ansible-galaxy.

Configuration of a collection in requirements :

```Bash
collections:
  - name: namespace.collectionName
    type: galaxy
```

So to create the requirements.yml file and install the plugin my requirements looks like :

```Bash
collections:
  - name: azure.azcollection
    type: galaxy
```

#### Playbook

The playbook.yml file will contain tasks and instructions for performing the audit using the oscap tool, as well as for saving the audit report. It will also run the ansible roles that are in my Github repository.

```Bash
---
- name: Run roles and SCAP audit
  hosts: dunab13-VM
  remote_user: DunaAdmin
  become: yes # true
  # roles:
  #   - "sudo"
  #   - ...
  tasks:
    - name: Install SCAP
      yum:
        name:
          - openscap-scanner
          - scap-security-guide
        state: present

    - name: Run SCAP audit with ANSSI profile
      command:
        cmd: >-
            oscap xccdf eval
            --profile xccdf_org.ssgproject.content_profile_anssi_bp28_minimal
            --results /tmp/anssi_results.xml
            --report /tmp/anssi_report.html
            /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
      register: oscap_result
      ignore_errors: yes

    - name: Save audit report
      fetch:
        src: /tmp/anssi_report.html
        dest: ./audit_reports/audit_report.xml
        flat: yes
      tags:
      - verification
```

I modified the playbook so it uses the db13-VM as the target host to run the SCAP audit with the specified profile.

When I run my playbook, it targets the VM named "db13-VM" using the host name I specified in the inventory file and executes the SCAP audit with the specified profile. The audit report are saved in the audit_reports directory of my GitHub repository.

To run the playbook I need to use this command :

```Bash
ansible-playbook playbook.yml -i azure_rm.yml # or inventory.ini
```

*To be able to deploy the playbook on the right host, I need to either provide the host's dns or public IP address.*

What's great with using inventory.YML (so a dynamic inventory) is that I don't need to put manually or add a terraform template to add the host's public IP into the inventory. I just need to provide the plugin, key words (such as the name of the machine or part of it, or a specific group of VM, or the impacted OS).

With a inventory.INI I have to either put it manually (after the VM's creation which is not very devops like) or create a template file (file.tpl) and two resources in my deployment.

*Cf. this dos on terraform templates : [Template files](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file).*

In the inventory.tpl file I create a reference (I name it as I want).

inventory.tpl :

```Bash
[azure_vms]
dunab13-VM ansible_ssh_host={nic_public_ip} # {nic_public_ip} is the reference
```

Then I use this reference in the resource `data "template_file"`. I provide the file.tpl path in my repository and create a variable (that has the same name as my reference) and tell it that its value is the nic public ip address of the public ip (for the nic) resource created previously and that I want to recover.

```Bash
data "template_file" "inventory" {
  template = file("${path.module}/inventory.tpl")
  vars = {nic_public_ip=azurerm_public_ip.nic_public_ip.ip_address} # {reference=azurerm_public_ip.nic_public_ip.ip_address}
}
```

Then I create another resource that I call `xx_rendered` to create a file with this data that will be recovered (or renderded hence the name). I provide the resrouce data in the `content` part and add `rendered` at the end to specify it is recovered.

Then I provide a path (that I choose depending of my repository) and provide a file name with the extension I want (here .ini) so that the the file will be created at the right place, with the right extension and with the rendered data written in it.

```Bash
resource "local_file" "inventory_rendered" {
  content = data.template_file.inventory.rendered
  filename = "${path.module}/inventory.ini"
}
```

Finally I add a `depends on` in my VM's creation properties to make sure the file is created before the running of the playbook (that needs the inventory file).

```Bash
# Créez la machine virtuelle Azure
resource "azurerm_linux_virtual_machine" "VM" {
  name                = var.vm_name
  depends_on = [local_file.inventory_rendered] # type and name of the resource
```

This way, I can recover automatically (in a much more complex way) the public IP address of my host and deploy my playbook.

However it is much more simple to use the dynamic inventory to point the host to the ansible playbook which is why I use the dynamic playbook.

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
ansible-playbook playbook.yml -i azure_rm.yml
```

This runs the audit according to my schedule or when triggered manually, saves the audit report and allows me to monitor the results.

I had an error when I tried to install azcollections. After checking this [guide](https://stackoverflow.com/questions/71256239/azure-rm-ansible-plugin-fails-to-parse-dynamic-inventory) I found that it was not installed and that I could not modify it as it was on azure direclty and not my user.

So I had to use WSL, install ubuntu, terraform, ansible, the CLI and then use the following commands to install azcollections at the right place (ansible directory) :

```Bash
ansible-galaxy collection install azure.azcollection --force
```

*I had to use the `--force` as it would tell me it was installed if I did not use it and would not install it, such nonsense --'*.

And then :

```Bash
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
```

[&#8679;](#top)

<div id='Trivy'/>  

### **Roles**

In order to create the ansible roles I used this [github repository](https://github.com/GSA/ansible-os-rhel8/tree/main) and this [ansible galaxy role](https://galaxy.ansible.com/ui/standalone/roles/RedHatOfficial/rhel8_anssi_bp28_minimal/).

To generate a role and get the necessary files in my repo i need to do :

```Bash
ansible-galaxy init anssi
```

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

### **To deploy and manage resources with yaml file with Terrafom**

1) To initialize terraform

```bash
terraform init -upgrade
```

2) To visualize the changes that will happen by applying the files

```bash
terraform plan
```

3) To apply all the plan

```bash
tarreform apply
```

To avoid the `yes` approval demand :

```bash
tarreform apply -auto-approve
```

4) To delete all resources

```bash
terraform destroy
```

[&#8679;](#top)

### To generate ssh keys pairs

```Bash
ssh-keygen -t rsa -b 2048
```

[&#8679;](#top)

</div>