#!/bin/bash

set -e
RESOURCE_PREFIX=$(terraform -chdir=terraform output -raw ownstak_resource_prefix)
export AWS_REGION=$(terraform -chdir=terraform output --raw ownstak_aws_region)

# Ensure the prefix is not empty
if [ -z "$RESOURCE_PREFIX" ]; then
    echo "Error: Resource prefix terraform output is empty"
    exit 1
fi

# List all lambda functions that will be deleted
echo "Lambda functions to be deleted:"
echo "================================"
lambda_functions=()
for arn in $(aws resourcegroupstaggingapi get-resources \
  --resource-type-filters lambda:function \
  --tag-filters Key=OwnstakPrefix,Values="$RESOURCE_PREFIX" \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output text); do
    func_name=$(echo $arn | awk -F: '{print $NF}')
    lambda_functions+=("$func_name")
    echo "  - $func_name"
done

if [ ${#lambda_functions[@]} -eq 0 ]; then
    echo "No lambda functions found with prefix: $RESOURCE_PREFIX"
else
    echo ""
    echo "Found ${#lambda_functions[@]} lambda function(s) to delete."
    echo ""
    
    # Check if --auto-approve is passed as first argument
    if [ "$1" = "--auto-approve" ]; then
        echo "Auto-approve enabled. Proceeding with lambda function deletion..."
        confirm="yes"
    else
        read -p "Are you sure you want to delete these lambda functions? (yes/no): " confirm
    fi
    
    if [ "$confirm" != "yes" ]; then
        echo "Lambda function deletion cancelled."
        exit 0
    fi
    
    echo ""
    echo "Deleting lambda functions..."
    for func_name in "${lambda_functions[@]}"; do
        echo "Deleting $func_name"
        aws lambda delete-function --function-name "$func_name"
    done
fi

(cd terraform && terraform destroy "$@")