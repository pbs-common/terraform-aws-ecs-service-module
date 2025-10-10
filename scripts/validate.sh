#!/usr/bin/env bash

# Unofficial bash strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

GIT_ROOT=$(git rev-parse --show-toplevel)
pushd "$GIT_ROOT" >/dev/null
export AWS_DEFAULT_REGION='us-east-1'
terraform init -upgrade -backend=false
terraform validate
git add .terraform.lock.hcl
