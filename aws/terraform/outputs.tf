output "ownstak_alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "ownstak_aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "ownstak_wildcard_domain" {
  description = "DNS wildcard domain for Ownstak sites"
  value       = var.ownstak_wilcard_domain
}

output "ownstak_resource_prefix" {
  description = "Resource prefix"
  value       = var.resource_prefix
}

output "ownstak_lambda_role" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution.arn
}

output "ownstak_certificate_arn" {
  description = "ARN of the ACM certificate for the wildcard domain"
  value       = var.certificate_arn != null ? var.certificate_arn : aws_acm_certificate_validation.wildcard[0].certificate_arn
}

output "ci_user_name" {
  description = "Name of the CI IAM user"
  value       = aws_iam_user.ci.name
}
