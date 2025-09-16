#!/bin/bash

# Check if resource prefix parameter is provided
if [ $# -eq 0 ]; then
    echo "Error: Resource prefix parameter is required"
    echo "Usage: $0 <resource_prefix>"
    echo "Example: $0 dev"
    exit 1
fi

RESOURCE_PREFIX="$1"

for arn in $(aws resourcegroupstaggingapi get-resources \
  --resource-type-filters lambda:function \
  --tag-filters Key=OwnstakPrefix,Values="$RESOURCE_PREFIX" \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output text); do
    func_name=$(echo $arn | awk -F: '{print $NF}')
    echo "Deleting $func_name"
    aws lambda delete-function --function-name "$func_name"
done