# OwnStak Providers

This repository provides Terraform templates for deploying OwnStak infrastructure to multiple cloud providers. OwnStak allows you to host your own sites with a comprehensive infrastructure-as-code solution.

## Cloud Providers

### AWS
Deploy OwnStak infrastructure to Amazon Web Services with a complete setup including Application Load Balancer, ECS Fargate, S3 buckets, and IAM roles.

📖 **[View AWS Documentation →](./aws/README.md)**

## Prerequisites

- Terraform >= 1.0.
- Cloud provider CLI configured with appropriate credentials.
- A domain or subdomain to host your sites.

## Architecture

Each cloud provider template creates:
- Load balancer for traffic distribution
- Container orchestration for Ownstak Lambda Proxy
- Storage buckets for assets
- Identity and access management roles
- Auto-scaling capabilities

## Contributing

This repository is designed to support multiple cloud providers. Each provider directory contains its own Terraform configuration and documentation.
