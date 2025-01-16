# Presentation # 


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

