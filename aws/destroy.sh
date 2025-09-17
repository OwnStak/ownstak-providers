#!/bin/bash

set -e

RESOURCE_PREFIX=$(cd terraform && terraform output -raw ownstak_resource_prefix)

# Ensure the prefix is not empty
if [ -z "$RESOURCE_PREFIX" ]; then
    echo "Error: Resource prefix terraform output is empty"
    exit 1
fi

for arn in $(aws resourcegroupstaggingapi get-resources \
  --resource-type-filters lambda:function \
  --tag-filters Key=OwnstakPrefix,Values="$RESOURCE_PREFIX" \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output text); do
    func_name=$(echo $arn | awk -F: '{print $NF}')
    echo "Deleting $func_name"
    aws lambda delete-function --function-name "$func_name"
done

(cd terraform && terraform destroy)