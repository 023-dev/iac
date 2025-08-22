output "cdn_distribution_id" {
  description = "CDN CloudFront distribution ID"
  value       = aws_cloudfront_distribution.cdn.id
}

output "cdn_distribution_arn" {
  description = "CDN CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.cdn.arn
}

output "cdn_domain_name" {
  description = "CDN CloudFront domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "frontend_distribution_id" {
  description = "Frontend CloudFront distribution ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "frontend_distribution_arn" {
  description = "Frontend CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.frontend.arn
}

output "frontend_domain_name" {
  description = "Frontend CloudFront domain name"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "dev_frontend_distribution_id" {
  description = "Dev Frontend CloudFront distribution ID"
  value       = aws_cloudfront_distribution.dev_frontend.id
}

output "dev_frontend_distribution_arn" {
  description = "Dev Frontend CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.dev_frontend.arn
}

output "dev_frontend_domain_name" {
  description = "Dev Frontend CloudFront domain name"
  value       = aws_cloudfront_distribution.dev_frontend.domain_name
}

# Origin Access Control IDs
output "oac_ids" {
  description = "Origin Access Control IDs"
  value = {
    dev_abs    = aws_cloudfront_origin_access_control.dev_abs.id
    prod_abs   = aws_cloudfront_origin_access_control.prod_abs.id
    dev_origin = aws_cloudfront_origin_access_control.dev_origin.id
    front_dev  = aws_cloudfront_origin_access_control.front_dev.id
    fe_dev     = aws_cloudfront_origin_access_control.fe_dev.id
  }
}
