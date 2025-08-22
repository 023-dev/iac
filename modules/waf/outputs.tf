output "web_acl_id" {
  description = "WAF Web ACL ID"
  value       = aws_wafv2_web_acl.unretired_prod.id
}

output "web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = aws_wafv2_web_acl.unretired_prod.arn
}

output "web_acl_name" {
  description = "WAF Web ACL name"
  value       = aws_wafv2_web_acl.unretired_prod.name
}

output "log_group_name" {
  description = "WAF CloudWatch log group name"
  value       = aws_cloudwatch_log_group.waf_log_group.name
}

output "log_group_arn" {
  description = "WAF CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.waf_log_group.arn
}
