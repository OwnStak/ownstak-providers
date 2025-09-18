# OwnStak AWS Infrastructure Terraform Template

This Terraform template deploys the OwnStak infrastructure to AWS, allowing you to host your own sites. It creates all the necessary AWS resources for running your OwnStak cloud backend in a single, comprehensive infrastructure-as-code solution.

## Resources Created

### Application Load Balancer (ALB)
- Application Load Balancer with HTTP/HTTPS listeners
- Target group with health checks
- Security groups for ALB and ECS tasks
- Support for both internet-facing and internal ALBs

### ECS (Elastic Container Service)
- ECS Fargate cluster
- ECS service with auto-scaling
- Task definition with ARM64 architecture
- CloudWatch log group with 60-day retention
- Auto-scaling policies based on CPU and memory utilization

### S3 Buckets
- S3 buckets for assets and compute storage
- Public access blocks and bucket policies
- Support for VPC endpoint access

### IAM Roles
- ECS execution role with ECR access
- ECS task role with Lambda invocation permissions
- Lambda execution role with S3 access

## Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform >= 1.0** installed
3. **Wildcard domain** that will host your deployed sites.


## Usage


### Configure Variables
Copy the example variables file and customize it:
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific values, particularly:
- `ownstak_wilcard_domain`: Domain name for your sites (e.g., *.example.com). Make sure this domain has a hosted zone in your AWS account and region. Otherwise you won't be able to use the `automatic_dns` option.


### Initialize Terraform
```bash
terraform -chdir=terraform init
```

### Plan the Deployment
```bash
terraform -chdir=terraform plan
```

### Apply the Configuration
```bash
./apply.sh
```

#### Apply Options
- **Interactive mode**: `./apply.sh` - Standard terraform apply with confirmation prompts
- **Auto-approve mode**: `./apply.sh --auto-approve` - Skip confirmation prompts and apply automatically
- **With variables**: `./apply.sh -var="key=value"` - Pass terraform variables

## Configuration Options

### Resource Naming
- **Resource Prefix**: Must be 14 characters or less to avoid AWS resource name limits
- This constraint exists because AWS has limits on resource names (e.g., Lambda functions: 64 chars, S3 buckets: 63 chars)
- The prefix is used for all resources: ALB, ECS cluster, S3 buckets, IAM roles, etc.
- Example: `ownstak-tf` (10 chars) leaves room for additional suffixes

### VPC Configuration
- **Custom VPC**: Provide `vpc_id`, `public_subnet_ids`, and `private_subnet_ids`. Default VPC and Subnets will be used otherwise.

### ALB Configuration
- **Internet-facing**: Set `use_internal_alb = false` (default)
- **Internal**: Set `use_internal_alb = true` for private ALBs

### ECS Configuration
- **CPU/Memory**: Adjust `instance_cpu` and `instance_memory` based on your needs
- **Scaling**: Configure `min_instances` and `max_instances` for auto-scaling
- **Architecture**: Currently set to ARM64 for cost efficiency


## Important Notes

### Certificate Requirements
- The ACM certificate must be in the same region as the ALB
- Certificate must be validated and in "ISSUED" status


## Outputs

The template provides the following outputs that are required for deploying your OwnStak sites:

- `ownstak_alb_dns_name`: DNS name of the Application Load Balancer. When `automatic_dns` is disabled, the CNAME record between your `ownstak_wildcard_domain` and `ownstak_alb_dns_name` will have to be created manually.
- `ci_user_name`: IAM User that should be used by your CI to deploy sites to your infra.
- `ownstak_aws_region`: AWS region where resources are deployed
- `ownstak_wildcard_domain`: DNS wildcard domain for OwnStak sites
- `ownstak_resource_prefix`: Resource prefix used for naming
- `ownstak_lambda_role`: ARN of the Lambda execution role

### Using Outputs with OwnStak CLI

After successful deployment, you'll need to set these outputs as environment variables before running the OwnStak CLI. Each Terraform output maps to a specific environment variable:

| Terraform Output | Environment Variable | Description |
|------------------|---------------------|-------------|
| `ownstak_aws_region` | `OWNSTAK_AWS_REGION` | AWS region for resource access |
| `ownstak_wildcard_domain` | `OWNSTAK_WILDCARD_DOMAIN` | Domain pattern for your sites |
| `ownstak_resource_prefix` | `OWNSTAK_RESOURCE_PREFIX` | Resource naming prefix |
| `ownstak_lambda_role` | `OWNSTAK_LAMBDA_ROLE` | Lambda execution role ARN |

To get the values, use `terraform output -raw <output_name>` for each output, then set the corresponding environment variable. Once all environment variables are set, run:

```bash
npx ownstak deploy --provider aws
```

## Cleanup

To destroy all Terraform-managed resources:
```bash
./destroy.sh
```

**Important**: Lambda functions created by OwnStak deployments are not managed by this Terraform template and will be deleted separately by `destroy.sh`. It is important not to leave orphan functions as they would be attached to a now-deleted IAM Role.

#### Destroy Options
- **Auto-approve mode**: `./destroy.sh --auto-approve` - Skips confirmation prompts and deletes lambda functions automatically



