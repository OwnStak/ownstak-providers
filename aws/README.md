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

See [Configuration Options](#configuration-options) for more details.

### Initialize Terraform
```bash
terraform init
```

### Plan the Deployment
```bash
terraform plan
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

### Basic Configuration
- `aws_region` - AWS region for deployment (default: "us-east-1")
- `resource_prefix` - Unique identifier that prefixes all AWS resource names. Required if deploying multiple instances to the same account/region. Must be 14 characters or less to avoid AWS resource name limits (default: "ownstak")

### VPC Configuration
- `vpc_id` - Custom VPC ID (optional, uses default VPC if not provided)
- `public_subnet_ids` - List of public subnet IDs for the ALB. Required if using custom VPC. The ALB must be in public subnets to receive internet traffic or on a private subnet where public traffic is routed to, in which case `use_internal_alb = false` must be set. This is common if public traffic is routed through a firewall for example.
- `private_subnet_ids` - List of private subnet IDs for ECS tasks. Required if using custom VPC
- `vpc_s3_endpoint_id` - VPC S3 endpoint ID for private bucket access (optional)

### ALB Configuration
- `use_internal_alb` - Set to `true` for internal ALB (not directly internet-facing), `false` for internet-facing ALB (default: false)

### ECS Configuration
- `instance_cpu` - ECS task CPU units (default: 512)
- `instance_memory` - ECS task memory in MB (default: 1024)
- `min_instances` - Minimum number of ECS instances for auto-scaling (default: 2)
- `max_instances` - Maximum number of ECS instances for auto-scaling (default: 6)
- `ecr_image` - ECR image URI for the ECS task (default: "public.ecr.aws/ownstak/ownstak-proxy:latest")

### DNS and Certificate Configuration
- `ownstak_wilcard_domain` - Wildcard domain for your OwnStak sites (e.g., "*.example.com") - **Required**
- `automatic_dns` - Set to `true` to automatically create DNS records and certificate via Route53 (default: true)
- `domain_zone_id` - Route53 hosted zone ID for the domain (optional, auto-detected if not provided)
- `certificate_arn` - Custom ACM certificate ARN (optional, created automatically if not provided and `automatic_dns = true`)


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



