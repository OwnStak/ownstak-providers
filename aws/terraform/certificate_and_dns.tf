# Extract the domain name from the wildcard domain (e.g., "*.example.com" -> "example.com")
locals {
  domain_name = replace(var.ownstak_wilcard_domain, "*.", "")
}

# Data source to find the Route53 hosted zone
data "aws_route53_zone" "main" {
  count = var.domain_zone_id == null ? 1 : 0
  name  = local.domain_name
}

# ACM Certificate for the wildcard domain
resource "aws_acm_certificate" "wildcard" {
  count = var.certificate_arn == null ? 1 : 0

  domain_name       = var.ownstak_wilcard_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.resource_prefix}-wildcard-cert"
  })
}

# DNS validation records for the certificate
resource "aws_route53_record" "cert_validation" {

  for_each = {
    for dvo in aws_acm_certificate.wildcard[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.domain_zone_id != null ? var.domain_zone_id : data.aws_route53_zone.main[0].zone_id
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "wildcard" {
  count = var.certificate_arn == null ? 1 : 0

  certificate_arn         = aws_acm_certificate.wildcard[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m"
  }
}

# CNAME record pointing the wildcard domain to the ALB
resource "aws_route53_record" "wildcard_cname" {
  zone_id = var.domain_zone_id != null ? var.domain_zone_id : data.aws_route53_zone.main[0].zone_id
  name    = var.ownstak_wilcard_domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.main.dns_name]

  depends_on = [aws_lb.main]
}
