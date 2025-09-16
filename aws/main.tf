terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_vpc" "default" {
  count   = var.use_default_vpc ? 1 : 0
  default = true
}


data "aws_subnets" "default" {
  # Attaching too many subnets is counter-productive, 2 is enough for multiAZ
  # Unless the user specifies subnets manually, we take 2 out of the (generally 6)
  # default subnets.
  count = 2
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

locals {
  vpc_id           = var.use_default_vpc ? data.aws_vpc.default[0].id : var.vpc_id
  public_subnets   = var.use_default_vpc ? data.aws_subnets.default[0].ids : var.public_subnet_ids
  private_subnets  = var.use_default_vpc ? data.aws_subnets.default[0].ids : var.private_subnet_ids
  
  common_tags = merge(var.tags, {
    Name = var.resource_prefix
    Project = "Ownstak"
    OwnstakPrefix = var.resource_prefix
  })
}
