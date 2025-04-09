#!/bin/bash


# Author  : Enzyro
# Version : 1.0
# Brief   : Emulates a fake terraform CI/CD pipeline
set -e

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 0 ] || die "Usage : $0"

terraform init -input=false
terraform fmt -recursive
terraform plan -out=./tfplan -input=false

terraform apply ./tfplan

