# Setup Up #

## Environment Configurations ## 

```zsh
# Login to Az CLI as this auth is used by Terraform and Ansible
# Talk about how Ansible Authenticates to Azure.. EnvVars, Credentials File, SPN, Managed Identity, or CLI. 
# Can be defined differently per Task/Module. 
az login 

# Set AzCLI to output to Table
az config set core.output=table

# Validate Tools
ansible --version

terraform --version

az --version
```

## Whiteboard Talking Points ##

```bash
# KISS 

When it comes to DevOps I can’t say this enough… 

KISS.. Simply put Complexity Kills productivity, ALWAYS. 
Keep it Simple Stupid.. 

The More complex a solution is, the more effort and work that will go into maintaining it.. This is the antithesis to what DevOps is supposed to be. 
Avoid Monolithic solutions. Learn to modularize your solutions. 

Your not a Dev, so don’t try to be one. Just because DEV comes first in DevOps doesn’t mean you need become a DEV. 
When you are designing your Solution, don’t “write code” in your solutions.. Often the languages are not designed for this (HCL/YAML/JSON) 
If an advanced “Code” solution is needed - then have your solutions call and consume them or process the results inline. 

# Organize Tools
- Dev = FrontEnd/BackEnd/Package/Artifacts
- Ops = IaC, ConfigMgmt, Image Building and Distribution 
- Draw and move icons
- Describe each tool and function
- Ansible Swiss Army Knife

# Ansible Notes

## How Ansible works
Ansible works by connecting to your nodes and pushing out small programs, called "Ansible modules" to them. Ansible then executes these modules (over SSH by default), and removes them when finished. Your library of modules can reside on any machine, and there are no servers, daemons, or databases required.

## Control Machine 
There can be multiple remote machines which are handled by one control machine. So, for managing remote machines we have to install Ansible on control machine. 
  - Does not support Windows (but can use WSL or Docker)
  - No Database
  - Requires Python3 and PIP 

# Python and YAML
Ansible uses YAML syntax for expressing Ansible playbooks. But the modules and execution leverages Python. 
YAML (Yet another Markup Language)
- Key-Value Pairs to represent data

# Ansible Ad-Hoc Commands
-- Before we get into Playbooks and INventory Files.. Understand ad-hoc usage
# F= parallel runs (or forks)
ansible GROUPNAME -a "/sbin/reboot" -f 12
ansible GROUPNANE -m copy -a "src = /etc/yum.conf dest = /tmp/yum.conf"
ansible GROUPNAME -m apt -a "name = nginx state = present"
ansible GROUPNAME -m apt -a "name = nginx state = absent"
ansible GROUPNAME -m apt -a "name = nginx state =  latest" 
ansible localhost -m ping


# Ansible Playbooks
- Playbooks represent a single solution 
- ie WebApplication with roles used to deplay FrontEnd, Middle Tier, Backend

name: This tag specifies the name of the Ansible playbook. As in what this playbook will be doing. Any logical name can be given to the playbook.

hosts: This tag specifies the lists of hosts or host group against which we want to run the task. The hosts field/tag is mandatory. It tells Ansible on which hosts to run the listed tasks. The tasks can be run on the same machine or on a remote machine. One can run the tasks on multiple machines and hence hosts tag can have a group of hosts’ entry as well.

vars: Vars tag lets you define the variables which you can use in your playbook. Usage is similar to variables in any programming language.

tasks: All playbooks should contain tasks or a list of tasks to be executed. Tasks are a list of actions one needs to perform. A tasks field contains the name of the task. This works as the help text for the user. It is not mandatory but proves useful in debugging the playbook. Each task internally links to a piece of code called a module. A module that should be executed, and arguments that are required for the module you want to execute.


# Inventory 
- Dynamic
- YML vs INI
- Organization

# Ansible Variables # 
Variable in playbooks are very similar to using variables in any programming language. It helps you to use and assign a value to a variable and use that anywhere in the playbook. One can put conditions around the value of the variables and accordingly use them in the playbook.

Keywords
block − Ansible syntax to execute a given block.
name − Relevant name of the block - this is used in logging and helps in debugging that which all blocks were successfully executed.
action − The code next to action tag is the task to be executed. The action again is a Ansible keyword used in yaml.
register − The output of the action is registered using the register keyword and Output is the variable name which holds the action output.
always − Again a Ansible keyword , it states that below will always be executed.
msg − Displays the message.

Variable Precedence: 
- Ansible gives precedence to variables that were defined more recently, more actively, and with more explicit scope. Variables in the defaults folder inside a role are easily overridden.


# Ansible Roles # 
Roles provide a framework for fully independent, or interdependent collections of variables, tasks, files, templates, and modules. In Ansible, the role is the primary mechanism for breaking a playbook into multiple files. This simplifies writing complex playbooks, and it makes them easier to reuse. The breaking of playbook allows you to logically break the playbook into reusable components.

Each role is basically limited to a particular functionality or desired output, with all the necessary steps to provide that result either within that role itself or in other roles listed as dependencies. Roles are not playbooks. Roles are small functionality which can be independently used but have to be used within playbooks. There is no way to directly execute a role. Roles have no explicit setting for which host the role will apply to.

Top-level playbooks are the bridge holding the hosts from your inventory file to roles that should be applied to those hosts.
  - Reuse and collaborate of common tasks (what we typically think of as modules)
  - Roles perform a repetive task that is consumed in playbooks. 
  - Provide full life-cycle mgmt of a solution
  - De-Facto enfocement of standards and policies. 


# Ansible Modules #
- Sophisticated interactions and logic of a unit of work
- Jinja, Python, or really any tool.
- Abstract complexity away from users to make more powerful automation


```

```cli

# List all installed modules
ansible-doc -l

# Details on Module
ansible-doc ping
ansible-doc azure.azcollection.azure_rm_resourcegroup

# Show Ansible-vault
ansible-vault create secret.yml
ansible-vault view secret.yml

# Show Creating Ansible Role / talk about what this is and the folder structure
ansible-galaxy init sample.role
```

## Validate Ansible ##

Create a new file called testing.yml and execute.

```yaml
---
- name: test ansible installation
  hosts: localhost
  connection: local
  gather_facts: yes 
  tasks:
    - name: Print Hello MSG
      debug: msg='Hello from {{ ansible_facts['nodename'] }} running on {{ ansible_facts['os_family'] }}'
```

- Demonstrate passing Variables by updateding test.yml
- Show example Playbook

```yaml
---
---
- name: test ansible installation
  hosts: localhost
  connection: local
  gather_facts: yes
  vars:
    TEST: "World"
  tasks:
    - name: Print Hello MSG
      debug: msg='Hello from {{ ansible_facts['nodename'] }} running on {{ ansible_facts['os_family'] }}'

    - name: Print Hello MSG
      debug: msg='Hello {{ TEST }}'
```


```bash
## Inline (or ExtraVars) has precedence over all others. 
ansible-playbook demo/testVar.yml -e 'TEST="From Earth"'
```

- Develop using conditionals 
  - Register
  - IF/WHEN

```yaml
    # Deomonstrate When Condition from Ansible Facts
    - name: Update Packages DEBIAN
      become: yes 
      ansible.builtin.apt:
        update_cache: yes
      when: ansible_facts['os_family'] != 'Debian'
    
    - name: Update Packages DEBIAN
      become: yes 
      ansible.builtin.apt:
        update_cache: yes
      when: ansible_facts['os_family'] == 'Debian'
      register: aptUpdate
      
    - name: Print Hello MSG
      ansible.builtin.command:
        cmd: apt list --upgradable
      register: aptUpgradable
      when: aptUpdate.changed == true

    - name: Print Hello MSG
      debug: 
        msg: "{{ aptUpgradable }}"
```


## Deploy ResourceGroup with Ansible ##

Demonstrate Deploying Azure Resources with Ansible. 

```yaml
---
- name: Deploy Resource Group
  hosts: localhost
  gather_facts: no
  vars:
    AZURE_REGION: eastus2
    RESGROUP_NAME: ansibleDemo
    VMTags: 
      environment: Demo
      owner: BenTheBuilder
  tasks:
    - name: Create a resource group
      azure.azcollection.azure_rm_resourcegroup:
        name: "{{ RESGROUP_NAME }}"
        location: "{{ AZURE_REGION }}"
        tags: "{{ VMTags }}"
      register: azRG
```

```bash
# Add AzCollection
# https://docs.ansible.com/ansible/latest/collections/azure/azcollection/index.html
ansible-galaxy collection install azure.azcollection --force

# Deploy ResourceGroup
ansible-playbook demo/deployRG.yml
```


## Deploy Infrastructure ##

```bash
# Add Community Terraform Collection 
# https://docs.ansible.com/ansible/latest/collections/community/general/terraform_module.html
ansible-galaxy collection install community.general --force

# Review then trigger Playbook
ansible-playbook demo/deploy_tf.yml
```

## Setup Bastion Tunnels for Ansible ##

```bash
## Configure Bastion Tunnel ##
pip install -r requirements.txt

## Configure Permissions on bastion_tunnels_inventory.py if locked out
chmod +x /workspaces/lab-ansible-101/helper_scripts/bastion_tunnels_inventory.py

## Validate inventory is being generated correctly
ansible-inventory -i bastion_tunnels_inventory.py --list --yaml

## Validate Bastion Tunnel connection is good
ansible -i bastion_tunnels_inventory.py -m ping all
```

## Use Ansible to configure LINUXVM as Self-Hosted Agent for Repo ##

```bash
# Configure GitHub Token to EnvVar for Inline Var. 
export GITHUB_TOKEN=$(az keyvault secret show --name ansible-gh-token --vault-name ansibleDemo-kv --query value -o tsv)

# Call playbook passing GHToken
ansible-playbook -i bastion_tunnels_inventory.py demo/configureRunner.yml -e "GITHUB_TOKEN=$GITHUB_TOKEN"

```

## Use GH Actions and SH-Agent for CI/CD ##

- Configure with MSI (msftlabs-core-mgmt-identity)
- Install Az CLI
- Configure Windows Servers for WinRM connectivity from Ansible

``` bash
iex(iwr https://raw.githubusercontent.com/AlbanAndrieu/ansible-windows/refs/heads/master/files/ConfigureRemotingForAnsible.ps1).Content
```

- Encrypte Secrets with Ansible-Vault
- Test WinRM from Config Host

```bash
nc -w 3 -v 10.0.2.5 5986
```

- Test with Ansible

```bash
ansible -i inventory -m win_ping webservers
```
