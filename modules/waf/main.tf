# WAF Web ACL for Production
resource "aws_wafv2_web_acl" "unretired_prod" {
  name  = "unretired-prod-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule 1: AWS Managed Core Rule Set
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "CommonRuleSetMetric"
      sampled_requests_enabled    = true
    }
  }

  # Rule 2: AWS Managed Known Bad Inputs Rule Set
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "KnownBadInputsRuleSetMetric"
      sampled_requests_enabled    = true
    }
  }

  # Rule 3: Rate Limiting
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "RateLimitRuleMetric"
      sampled_requests_enabled    = true
    }
  }

  # Rule 4: Geo Blocking (if needed)
  rule {
    name     = "GeoBlockRule"
    priority = 4

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["CN", "RU"]  # Block China and Russia as example
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "GeoBlockRuleMetric"
      sampled_requests_enabled    = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                 = "unretiredProdWAF"
    sampled_requests_enabled    = true
  }

  tags = {
    Name        = "unretired-prod-waf"
    Environment = "production"
  }
}

# CloudWatch Log Group for WAF
resource "aws_cloudwatch_log_group" "waf_log_group" {
  name              = "/aws/wafv2/unretired-prod-waf"
  retention_in_days = 30

  tags = {
    Name = "unretired-prod-waf-logs"
  }
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "unretired_prod" {
  resource_arn            = aws_wafv2_web_acl.unretired_prod.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]

  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "cookie"
    }
  }
}

# WAF Association with ALB (if needed)
resource "aws_wafv2_web_acl_association" "alb_association" {
  count        = 1
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.unretired_prod.arn
}
