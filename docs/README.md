## Setup Up ##

```zsh
# Login to Az CLI as this auth is used by Terraform and Ansible
az login 

# Set AzCLI to output to Table
az config set core.output=table

# 



```

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
