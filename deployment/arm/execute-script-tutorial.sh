#!/bin/bash -eu

# user azure cli to create a azure resource group
az group create --l southcentralus \
    -n rg-mgrn-gha-scus-dev