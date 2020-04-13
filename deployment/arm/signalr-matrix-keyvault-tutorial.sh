#!/bin/bash -eu

# change directory to current directory
parent_path=$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd -P
)
cd "$parent_path"

# set parameters
while getopts "o:" opt; do
    case $opt in
        o)
            orgName=$OPTARG
        ;;
        \?)            
            echo "Invalid parameters! Required parameters are:  [-o] orgName"
        ;;   
    esac
done

# ensure parameters were provided
if [[ $# -eq 0 || -z $orgName ]]; then
    echo "Parameters missing! Required parameters are:  [-n] orgName"
    exit 1; 
fi

# set local variables
declare rgName="rg-$orgName-gha-scus-dev"
declare signalrName="sr-$orgName-gha-scus-dev"

# create the azure resource group
az group create --l southcentralus \
    -n $rgName

# create the azure deployment
az group deployment create -g $rgName \
    -n "$orgName-deployment" \
    -p name=$signalrName \
    -f signalr.json

# get primary connection string
declare signalrPrimaryConnectionString=$(az signalr key list -n $signalrName -g $rgName --query primaryConnectionString -o tsv)

# TODO: check for null/empty
#       put keyvault name in secrets and pass as parameter
az keyvault secret set --n "kv-secret-$signalrName-primary-connection-string" \
    --vault-name kv-gha-scus-dev \
    --value $signalrPrimaryConnectionString
