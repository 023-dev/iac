# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# EC2 Outputs
output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = module.ec2.bastion_public_ip
}

output "dev_instance_private_ip" {
  description = "Development instance private IP"
  value       = module.ec2.dev_private_ip
}

output "prod_instance_private_ip" {
  description = "Production instance private IP"
  value       = module.ec2.prod_private_ip
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.ec2.alb_dns_name
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_address" {
  description = "RDS address"
  value       = module.rds.db_instance_address
  sensitive   = true
}

# S3 Outputs
output "s3_bucket_names" {
  description = "S3 bucket names"
  value       = module.s3.bucket_names
}

# CloudFront Outputs
output "cloudfront_distributions" {
  description = "CloudFront distribution information"
  value = {
    cdn = {
      id          = module.cloudfront.cdn_distribution_id
      domain_name = module.cloudfront.cdn_domain_name
    }
    frontend = {
      id          = module.cloudfront.frontend_distribution_id
      domain_name = module.cloudfront.frontend_domain_name
    }
    dev_frontend = {
      id          = module.cloudfront.dev_frontend_distribution_id
      domain_name = module.cloudfront.dev_frontend_domain_name
    }
  }
}

# Lambda Outputs
output "lambda_functions" {
  description = "Lambda function information"
  value = {
    convert_mp4_to_hls = {
      function_name = module.lambda.convert_mp4_to_hls_function_name
      function_arn  = module.lambda.convert_mp4_to_hls_function_arn
    }
    quicksetup_lifecycle = {
      function_name = module.lambda.quicksetup_lifecycle_function_name
      function_arn  = module.lambda.quicksetup_lifecycle_function_arn
    }
  }
}

# WAF Outputs
output "waf_web_acl" {
  description = "WAF Web ACL information"
  value = {
    id   = module.waf.web_acl_id
    arn  = module.waf.web_acl_arn
    name = module.waf.web_acl_name
  }
}

# Route53 Outputs
output "route53_zone" {
  description = "Route53 hosted zone information"
  value = {
    zone_id      = module.route53.hosted_zone_id
    domain_name  = module.route53.domain_name
    name_servers = module.route53.name_servers
  }
}
