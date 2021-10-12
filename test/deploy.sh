#!/bin/bash

RG="rg-ormonitor"
LOCATION="southcentralus"
SRCACCT="stormonsource"
DESTACCT="stormontarget"

az group create --name $RG --location $LOCATION 

echo "Creating accounts..."
az deployment group create \
    --name TestDeployment \
    --resource-group $RG  \
    --template-file step01.json \
    --parameters "sourceStorageAccountName=$SRCACCT" \
        "targetStorageAccountName=$DESTACCT"        

echo "Sleeping 30s..."
sleep 30s

echo "Creating target object replication endpoint..."
az deployment group create \
    --name TestDeployment \
    --resource-group $RG  \
    --template-file step02.json \
    --parameters "sourceStorageAccountName=$SRCACCT" \
        "targetStorageAccountName=$DESTACCT"

POLICY=$(az storage account or-policy list --account-name $DESTACCT --query '[0].policyId' --output tsv)
RULE=$(az storage account or-policy list --account-name $DESTACCT --query '[0].rules[0].ruleId' --output tsv)

echo "Creating source object replication endpoint..."
az deployment group create \
    --name TestDeployment \
    --resource-group $RG  \
    --template-file step03.json \
    --parameters "sourceStorageAccountName=$SRCACCT" \
        "targetStorageAccountName=$DESTACCT" \
        "policyId=$POLICY" \
        "ruleId=$RULE"


STORAGEACCOUNTID=$(az storage account show --name $SRCACCT --query 'id' --output tsv)

echo "Deploying Object Replication Monitor resources..."
az deployment group create --resource-group $RG --template-file ../src/azureDeploy.json --parameters SourceStorageAccountName=$SRCACCT SourceStorageAccountResourceId=$STORAGEACCOUNTID

echo "Sleeping 30s..."
sleep 30s

echo "Assigning Storage Blob Data Reader permission on the source storage account to the Logic App..."
LOGICAPPPRINCIPALID=$(az resource show -g $RG --resource-type Microsoft.Logic/workflows -n Get-ObjectReplicationData --query "identity.principalId" --output tsv)
az role assignment create --scope $STORAGEACCOUNTID --role "Storage Blob Data Reader" --assignee $LOGICAPPPRINCIPALID --description "Logic App to read data from Storage Account"
