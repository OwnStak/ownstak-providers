# OwnStak Providers

This repository provides Terraform templates for deploying OwnStak infrastructure directly to your cloud providers. OwnStak allows you to host your own sites with a comprehensive infrastructure-as-code solution.

This is an alternative to [OwnStak's managed service](https://console.ownstak.com), which orchestrates and manages your infrastructure for you. 

For a complete guide on the self-hosting workflow, see our [Self-Hosting Documentation](https://docs.ownstak.com/self-hosting).



## Cloud Providers

### AWS
Deploy OwnStak infrastructure to Amazon Web Services with a complete setup including Application Load Balancer, ECS Fargate, S3 buckets, and IAM roles.

📖 **[View AWS Documentation →](./aws/README.md)**

## Prerequisites

- Terraform >= 1.0
- Cloud provider CLI configured with appropriate credentials (e.g., AWS CLI)
- A domain or subdomain to host your sites, for example *.ownstak.mydomain.com

## Architecture

Each cloud provider template creates:
- Load balancer for traffic distribution
- Container orchestration for OwnStak Lambda Proxy
- Storage buckets for assets
- Identity and access management roles
- Auto-scaling capabilities