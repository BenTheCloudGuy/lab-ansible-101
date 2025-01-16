#!/bin/bash

# Global Variables
RESOURCE_GROUP="ansibleDemo"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
BASTION_NAME="${RESOURCE_GROUP}-bastion"

# VM Variables
LINUXVM="${RESOURCE_GROUP}vm01" 
WINVM01="${RESOURCE_GROUP}vm02" 
WINVM02="${RESOURCE_GROUP}vm03"

# Convert VM names to lowercase
LINUXVM=${LINUXVM,,}
WINVM01=${WINVM01,,}
WINVM02=${WINVM02,,}

# VM Configs
VM_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Compute/virtualMachines/${LINUXVM}"
RESOURCE_PORT="22"
LOCAL_PORT="10022"
az network bastion tunnel --name "${BASTION_NAME}" --resource-group "${RESOURCE_GROUP}" --target-resource-id "${VM_RESOURCE_ID}" --resource-port "${RESOURCE_PORT}" --port "${LOCAL_PORT}"



# WIN01 VM Configs
VM_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Compute/virtualMachines/${WINVM01}"
RESOURCE_PORT="5986"
LOCAL_PORT="15986"
az network bastion tunnel --name "${BASTION_NAME}" --resource-group "${RESOURCE_GROUP}" --target-resource-id "${VM_RESOURCE_ID}" --resource-port "${RESOURCE_PORT}" --port "${LOCAL_PORT}"


# WIN02 VM Configs
VM_RESOURCE_ID="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}/providers/Microsoft.Compute/virtualMachines/${WINVM02}"
RESOURCE_PORT="5986"
LOCAL_PORT="25986"
az network bastion tunnel --name "${BASTION_NAME}" --resource-group "${RESOURCE_GROUP}" --target-resource-id "${VM_RESOURCE_ID}" --resource-port "${RESOURCE_PORT}" --port "${LOCAL_PORT}"
