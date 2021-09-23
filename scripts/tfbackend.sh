#!/bin/bash

# usage tfbackend.sh ResourceGroupName StorageAccountName ContainerName SubscriptionId

RESOURCE_GROUP_NAME=${1:-terraform-backend-rg}
STORAGE_ACCOUNT_NAME=${2:-terraformbackendsa}
CONTAINER_NAME=${3:-terraform-backend-container}
SUBSCRIPTIONID=${4}
LOCATION=${5:-norwayeast}

if [[ -z "$SUBSCRIPTIONID" ]]; then
    echo "Must provide Subscription ID as parameter" 1>&2
    echo "Usage ./tfbackend.sh ResourceGroupName StorageAccountName ContainerName SubscriptionId" 1>&2
    exit 1
fi

CURRENT_SUBSCRIPTION_NAME=$(az account show --query 'name' --output json)
CURRENT_SUBSCRIPTION_ID=$(az account show --query 'id' --output json)

az account set --subscription $SUBSCRIPTIONID

az account show --query '[name, id]'

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --location $LOCATION

CONNECTION_STRING=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --query connectionString --output json)

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --connection-string $CONNECTION_STRING