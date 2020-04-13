#!/bin/bash -eu

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

if [[ $# -eq 0 || -z $orgName ]]; then
    echo "Parameters missing! Required parameters are:  [-n] orgName"
    exit 1; 
fi

rgName="rg-$orgName-gha-scus-dev"
signalrName="sr-$orgName-gha-scus-dev"

az group create --l southcentralus \
    -n $rgName

az group deployment create -g $rgName \
    -n "$orgName-deployment" \
    -p name=$signalrName \
    -f signalr.json
