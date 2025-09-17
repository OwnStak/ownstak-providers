variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "resource_prefix" {
  description = "Resource prefix for naming resources (14 characters max to avoid AWS resource name limits)"
  type        = string
  default     = "ownstak"
  
  validation {
    condition     = length(var.resource_prefix) <= 14
    error_message = "Resource prefix must be 14 characters or less to avoid AWS resource name limits (lambda functions, S3 buckets, etc.)."
  }
}

variable "use_default_vpc" {
  description = "Whether to use the default VPC"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "VPC ID (required if use_default_vpc is false)"
  type        = string
  default     = null
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (required if use_default_vpc is false)"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (required if use_default_vpc is false)"
  type        = list(string)
  default     = []
}

variable "use_internal_alb" {
  description = "Whether to create an internal ALB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (optional - will create certificate if not provided)"
  type        = string
  default     = null
}

variable "ownstak_wilcard_domain" {
  description = "ALB domain name"
  type        = string
}

variable "automatic_dns" {
  description = "Whether to automatically create DNS records for the domain"
  type        = bool
  default     = true
}

variable "domain_zone_id" {
  description = "Route53 hosted zone ID for the domain (optional - will look up by domain if not provided)"
  type        = string
  default     = null
}

variable "ecr_image" {
  description = "ECR image URI for the ECS task"
  type        = string
  default     = "public.ecr.aws/ownstak/ownstak-proxy:latest"
}

variable "console_url" {
  description = "Console URL (OwnStak internal use only)"
  type        = string
  default     = null
}

variable "instance_cpu" {
  description = "ECS task CPU units"
  type        = number
  default     = 512
}

variable "instance_memory" {
  description = "ECS task memory in MB"
  type        = number
  default     = 1024
}

variable "min_instances" {
  description = "Minimum number of ECS instances"
  type        = number
  default     = 2
}

variable "max_instances" {
  description = "Maximum number of ECS instances"
  type        = number
  default     = 6
}


variable "vpc_s3_endpoint_id" {
  description = "VPC S3 endpoint ID for private bucket access"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/__ownstak__/health"
}
