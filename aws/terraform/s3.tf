# S3 Buckets - derived from resource_prefix
locals {
  buckets = {
    assets = {
      name   = "${var.resource_prefix}-assets"
      public = true
    }
    permanent_assets = {
      name   = "${var.resource_prefix}-permanent-assets"
      public = true
    }
    compute = {
      name   = "${var.resource_prefix}-compute"
      public = false
    }
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = local.buckets

  bucket = each.value.name

  tags = merge(local.common_tags, {
    Name = each.value.name
  })

  # Everything in those buckets should be version controlled elsewhere, they are
  # only here to serve assets. 
  force_destroy = true
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "buckets" {
  for_each = aws_s3_bucket.buckets

  bucket = each.value.id

  block_public_acls       = !local.buckets[each.key].public || var.vpc_s3_endpoint_id != null
  ignore_public_acls      = !local.buckets[each.key].public || var.vpc_s3_endpoint_id != null
  block_public_policy     = !local.buckets[each.key].public || var.vpc_s3_endpoint_id != null
  restrict_public_buckets = !local.buckets[each.key].public || var.vpc_s3_endpoint_id != null
}

# S3 Bucket Policy for VPC Endpoint Access
resource "aws_s3_bucket_policy" "vpc_endpoint" {
  for_each = var.vpc_s3_endpoint_id != null ? {
    for k, v in aws_s3_bucket.buckets : k => v if local.buckets[k].public
  } : {}
  
  bucket = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadOnlyAccessFromVPCE"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${each.value.arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.vpc_s3_endpoint_id
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.buckets]
}

# S3 Bucket Policy for Internet Access (only for public buckets)
resource "aws_s3_bucket_policy" "internet" {
  for_each = var.vpc_s3_endpoint_id == null ? {
    for k, v in aws_s3_bucket.buckets : k => v if local.buckets[k].public
  } : {}

  bucket = each.value.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadOnlyAccessFromInternet"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${each.value.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.buckets]
}