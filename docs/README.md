# Presentation # 

## Slide 1 ##

```cli
Cloud Native: (ARM/BICEP)
Simplicity and Ease of Use: No external tooling or costs. 
Often gets access to latest APIs being developed by the same teams managing the Cloud. 

Ansible:
Simplicity and Ease of Use: Ansible uses a simple, human-readable YAML syntax to describe the desired state of your systems. This makes it accessible for IT professionals with specific domain expertise
Agentless Architecture: Ansible operates without requiring agents on the target machines, which simplifies management and reduces overhead
Idempotency: Tasks in Ansible can be run multiple times, making changes only if necessary, ensuring consistent results
Integration with Secrets Management: Ansible integrates well with various secrets management tools like Ansible Vault, Azure Key Vault, AWS Secrets Manager, and HashiCorp Vault

Chef:
Configuration Management: Chef excels in configuration management and is known for its robust ecosystem and community support
Infrastructure as Code: Chef uses Ruby-based DSL for writing configuration recipes, which can be a learning curve but offers powerful capabilities
Pull-based Configuration: Chef uses a pull-based model, where agents on the target machines pull configurations from a central server

Puppet:
Mature and Stable: Puppet is one of the oldest configuration management tools and is known for its stability and maturity
Declarative Language: Puppet uses a declarative language to define the desired state of the infrastructure, making it easier to understand and maintain
Strong Community and Ecosystem: Puppet has a strong community and a rich ecosystem of modules and integrations

Pulumi:
Multi-Language Support: Pulumi allows you to use popular programming languages like Python, JavaScript, TypeScript, and more, providing flexibility and extensibility
Cloud-Native: Pulumi is designed for modern cloud-native applications and integrates well with various cloud providers
Infrastructure as Code: Pulumi provides a programming language-based approach to infrastructure management, making it suitable for developers who prefer coding over configuration

Terraform:
Declarative Infrastructure Orchestration: Terraform uses HashiCorp Configuration Language (HCL) to define infrastructure, making it easy to manage and update
Multi-Cloud Support: Terraform provides a common syntax and platform to manage infrastructure across multiple cloud providers
State Management: Terraform maintains the state of your infrastructure, allowing you to track changes and manage resources efficiently

```

## Slide 2 ##

```cli

IaC comes in two main flavors.. Tools that deploy Infrastructure.. Tools that configure Infrastructure (ConfigMgmt)

```

## Slide 3 ##

```cli
PUSH vs PULL

Talk about how Push works vs Pull
Agent vs Agentless

Ansible = Push
Chef/Puppet = Pull

Authentication issues with Pull vs Push
```

## Slide 4 ##

```cli
Swiss Army Knife of DevOps Tools

Agentless - Ansible operates over SSH and WinRM, making it agentless and eliminating the need to install any software on remote systems PUSH vs PULLDeclarative Language -  Ansible uses a simple and human-readable YAML syntax to describe the desired state of your systems. 

IT professionals with specific domain expertise—like in network, security, or cloud—can create playbooks without having to learn a complicated coding language.

Idempotent – A task in Ansible could be ran multiple times only making changes if it needs to. You can run it once or 1000 times and it only makes change 1 time
```

## Slide 5 ##

```clie
Ansible Control Machine
This is what has Ansible Installed
This can be a Docker Image/Container, Your local laptop, or CI/CD Job Runner

Nodes
These are the endpoints you are configuring with Ansible
Can be your own local machine
These are defined as part of your Inventory


Playbooks are the instructions that you use define how nodes are configured
Uses YAML
```

## Setup Up ##

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

## Show Local CLI Commands ##

```cli
# -m = Module.. Ansible has many built-in modules such as ping. Validated connectivity to target host. 
ansible localhost -m ping

# List all installed modules
ansible-doc -l

# Details on Module
ansible-doc ping
ansible-doc azure.azcollection.azure_rm_resourcegroup
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

Demonstrate passing Variables by updateding test.yml

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
