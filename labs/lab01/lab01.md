# Lab 01 - Setup Environment #

## Workspace ##

- Fork Repo https://github.com/BenTheCloudGuy/lab-ansible-101
- Navigate to your GH Repo and Launch Codespaces using provided DevContainer located in the root of the Repo.
- You will eventually see a VSCode session open with all the installed tools and extensions needed.

> [!NOTE]
> The initial deployment of your codespace can take several minutes to complete. Just be patient.

Additional information on CodeSpaces can be found here: https://github.com/features/codespaces

## Login to Az CLI ##

- From the Terminal login to Az CLI and select your Tenant and Subscription.

```bash
az login
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code F5C39W4NS to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name           Subscription ID                       Tenant
-----  --------------------------  ------------------------------------  --------
[1]    msftlabs-poc-demo           00000000-0000-0000-0000-000000000000  MSFTLABS


The default is marked with an *; the default tenant is 'MSFTLABS' and subscription is 'msftlabs-poc-demo' (00000000-0000-0000-0000-000000000000).

Select a subscription and tenant (Type a number or Enter for no changes): 1

Tenant: MSFTLABS
Subscription: msftlabs-poc-demo (00000000-0000-0000-0000-000000000000)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug
```

## Configure Ansible for IaC ##

Ansible can deploy Azure Infrastructure as well as configure those resources. https://galaxy.ansible.com/ui/repo/published/azure/azcollection/

```bash
ansible-galaxy collection install azure.azcollection --force 
```

## Validate Ansible ##

Create a new file called local-test.yml and execute. 

```yaml
---

- name: test ansible installation
  hosts: localhost
  connection: local
  gather_facts: yes  # stop gathering facts for now
  tasks:
    - name: Print Hello MSG
      debug: msg='Hello from {{ ansible_facts['nodename'] }} running on {{ ansible_facts['os_family'] }}'
```

```bash
# Create File then open and copy the above code. 
touch labs/lab01/local-test.yml

# Execute ansible-playbook against our test file. You should see something similiar to below. S
ansible-playbook labs/lab01/local-test.yml 
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [test ansible installation] ****************************************************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************************************************************
ok: [localhost]

TASK [Print Hello MSG] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Hello from codespaces-c16751 running on Debian"
}

PLAY RECAP *****************************************************************************************************************************************
localhost                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

## Setup SPN to be used by Ansible ##

For Ansible to execute correctly you'll need to create a new SPN with sufficient permissions to perform the assigned tasks. For this Demo we want to assign it Owner to the Subscription because we are creating resources and assigning RBAC with it. 

```bash
# Export the variables (optional, for the current session)
export AZURE_TENANT=$(az account show --query tenantId -o tsv)
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Define the SPN name and role
SPN_NAME="ansible-spn"
ROLE="Owner"

# Create the SPN and Set it as Contributor to the target subscription.
SPN_OUTPUT=$(az ad sp create-for-rbac --name $SPN_NAME --role $ROLE --scopes /subscriptions/$(az account show --query id -o tsv) --query "{clientId: appId, clientSecret: password, tenantId: tenant}" -o json)

# Add ClientId & ClientSecret to Environment Variables
export AZURE_CLIENT_ID=$(echo $SPN_OUTPUT | jq -r '.clientId')
export AZURE_SECRET=$(echo $SPN_OUTPUT | jq -r '.clientSecret')



# Create Azure Credentials File for Ansible Auth
touch ~/.azure/credentials
echo "[default]" >> ~/.azure/credentials
echo "subscription_id=$AZURE_SUBSCRIPTION_ID" >> ~/.azure/credentials
echo "secret=$AZURE_SECRET" >> ~/.azure/credentials
echo "client_id=$AZURE_CLIENT_ID" >> ~/.azure/credentials
echo "tenant=$AZURE_TENANT" >> ~/.azure/credentials

```

## Create Our Resource Group ##

Create a new file called lab01.yml and copy the following code to it.

```yaml
---
- name: Create Azure Resource Group
  hosts: localhost
  tasks:
    - name: Create a resource group in Azure
      azure.azcollection.azure_rm_resourcegroup:
        name: ansible-lab01
        location: eastus
        tags:
          environment: lab
          owner: ansible
      register: result

    - name: Show result
      debug:
        var: result
```

```bash
touch labs/lab01/resourcegroup.yml
ansible-playbook labs/lab01/resourcegroup.yml
```


## Setup KeyVault and RBAC ## 

```yaml 
---
- name: Deploy Azure Lab Resources
  hosts: localhost
  vars:
    AZURE_REGION: eastus2
    RESGROUP_NAME: ansible-lab01

  tasks:
    - name: Create a resource group
      azure.azcollection.azure_rm_resourcegroup:
        name: "{{ RESGROUP_NAME }}"
        location: "{{ AZURE_REGION }}"
        tags:
          environment: lab
          owner: ansible
      register: azRG

    - name: Deploy Azure KeyVault 
      azure.azcollection.azure_rm_keyvault:
        vault_name: ansiblelab01kv
        resource_group: "{{ RESGROUP_NAME }}"
        location: "{{ AZURE_REGION }}"
        enabled_for_deployment: true
        enable_rbac_authorization: true
        vault_tenant: "{{ lookup ('env', 'AZURE_TENANT') }}"
        sku:
          name: standard
          family: A
        tags:
          environment: lab
          owner: ansible
      register: azKV

    - name: Configure SPN as Keyvault Contributor
      azure.azcollection.azure_rm_roleassignment:
        role_definition_id:
          "/subscriptions/{{ lookup ('env', 'AZURE_SUBSCRIPTION_ID') }}/providers/Microsoft.Authorization/roleDefinitions/f25e0fa2-a7c8-4377-a976-54943a77a395"
        assignee_object_id: "{{ SPN_APP_ID }}"
        scope: "/subscriptions/{{ lookup ('env', 'AZURE_SUBSCRIPTION_ID') }}/resourceGroups/{{ RESGROUP_NAME }}/providers/Microsoft.KeyVault/vaults/ansiblelab01kv"
```

## Simplify Variables Reuse ##

Add Community Collection
ansible-galaxy collection install community.general

## Wrap up LAB01 ##

We've configured everything we need to move forward with rest of the labs. We have a Workspace with Ansible installed and configured, Permissions in Azure and ResourceGroup Created.