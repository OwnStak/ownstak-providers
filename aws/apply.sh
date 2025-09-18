#!/bin/bash

set -e

(cd terraform && 

  terraform apply "$@"


  OWNSTAK_AWS_REGION=$(terraform output -raw ownstak_aws_region)
  OWNSTAK_WILDCARD_DOMAIN=$(terraform output -raw ownstak_wildcard_domain)
  OWNSTAK_RESOURCE_PREFIX=$(terraform output -raw ownstak_resource_prefix)
  OWNSTAK_LAMBDA_ROLE=$(terraform output -raw ownstak_lambda_role)

  echo ""
  echo "--------------------------------"
  echo ""
  echo "Use this command to deploy your sites to your OwnStak backend."
  echo "Replace 'my-project' with your project name, it will be used as a subdomain:"
  echo ""
  echo "OWNSTAK_AWS_REGION=$OWNSTAK_AWS_REGION OWNSTAK_WILDCARD_DOMAIN=$OWNSTAK_WILDCARD_DOMAIN OWNSTAK_RESOURCE_PREFIX=$OWNSTAK_RESOURCE_PREFIX OWNSTAK_LAMBDA_ROLE=$OWNSTAK_LAMBDA_ROLE npx ownstak deploy --provider-type aws --environment my-project"

) 