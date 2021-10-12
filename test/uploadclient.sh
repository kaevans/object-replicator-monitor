#!/bin/bash

RG="rg-objectreplicationmonitor"
LOCATION="southcentralus"
SRCACCT="stkirksource"
DESTACCT="stkirktarget"

STORAGEKEY=$(az storage account keys list --resource-group $RG --account-name $SRCACCT --query "[0].value" --output TSV)

for (( ; ; ))
do
   cd /mnt/c/temp/blobTest

   echo "[ hit CTRL+C to stop]"
   
   for f in $(ls); 
   do 
  	echo Processing $f ; 
	az storage blob upload -f $f -c logs -n $f --account-name $SRCACCT --account-key $STORAGEKEY
   done;

   sleep 5m
done
