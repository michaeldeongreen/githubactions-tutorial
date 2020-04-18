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
    echo "Parameters missing! Required parameters are:  [-o] orgName"
    exit 1; 
fi

# set local variables
declare customers=(luffy zorro usopp sanji)

#create resource groups
for customer in "${customers[@]}"
do
    # create the azure resource group
    az group create --l southcentralus \
        -n "rg-$orgName-$customer-dev" \
        -o none
done

# create deployments
declare pids=()
for customer in "${customers[@]}"
do
    # create the azure deployment
    printf "Creating $customer...\n"
    az deployment group create -g "rg-$orgName-$customer-dev" \
        -n "$orgName-$customer-deployment" \
        -f signalr-loop.json \
        -p orgName=$orgName customer=$customer &
    pids+=( "$!" )
done

# wait for all pids
for pid in ${pids[*]}; do
    wait $pid
done

echo "All Azure deployment groups created..."