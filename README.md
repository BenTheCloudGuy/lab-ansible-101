# Notes #

- Document setting up lab via devcontainer/GitHub Workspaces
  - validate ansible local working
  - login Az CLI
- Build Deck | Ansible 101
  - Review what Ansible is and where it belongs in the DevOps workflow
  - Talk through Requirements/Best Practices
  - Talk about options/setup/install
  - Talk about Magic Variables and Gather_Facts
  - Show some examples of both IaC and ConfigMgmt
  - Talk a bit about Ansible Tower and OpenSource Alternatives
  - Dive in to Idempotency (DEMO)
  - Github Integration
- Infrastructure (Bicep) - Requires Contributor and User
  - deploy VNET | 10.0.0.0/24
    - SUBNET (BASTION) | 10.0.0.0/26
    - SUBNET (EXTERNAL)| 10.0.0.0/27
    - SUBNET (INTERNAL)| 10.0.0.0/27
  - deploy NSGS
  - deploy BASTION SERVICE
  - deploy WEBSERVER VMs
  - deploy ELB
- Ansible
  - Configure Bastion Tunnel
  - Dynanmically create hosts.ini file
  - Execute Ansible Playbook to configure the host
    - Configure IIS
    - Configure Certificate
    - Configure Bindings
    - Configure Server Hardening Rules
- Demo
  - Explain how to clone repo
  - Walk through DevContainer setup


## Configure Bastion Tunnel ##

```bash
# Login via your Tenant
az login

# Configure Bastion Tunnel
az network bastion tunnel --name "MyBastion" --resource-group "MyResourceGroup" --target-resource-id "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyResourceGroup/providers/Microsoft.Compute/virtualMachines/vm1" --resource-port "3389" --port "113389"

az network bastion tunnel --name "MyBastion" --resource-group "MyResourceGroup" --target-resource-id "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/MyResourceGroup/providers/Microsoft.Compute/virtualMachines/vm1" --resource-port "3389" --port "123389"

# Execute playbook via bastion over custom port. 
ansible-playbook -i mylinuxvm -e ansible_host=127.0.0.1 -e ansible_port=10022
```
