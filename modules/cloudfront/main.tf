# Origin Access Control for S3 buckets
resource "aws_cloudfront_origin_access_control" "dev_abs" {
  name                              = "unretired-dev-abs-oac"
  description                       = "OAC for unretired-dev-abs bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "prod_abs" {
  name                              = "unretired-prod-abs-oac"
  description                       = "OAC for unretired-prod-abs bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "dev_origin" {
  name                              = "unretired-dev-origin-oac"
  description                       = "OAC for unretired-dev-origin bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "front_dev" {
  name                              = "front-dev-unretired-oac"
  description                       = "OAC for front-dev-unretired bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "fe_dev" {
  name                              = "fe-dev-unretired-oac"
  description                       = "OAC for fe-dev-unretired bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution 1: CDN for Video Streaming (EK668CQHBMBEI)
resource "aws_cloudfront_distribution" "cdn" {
  aliases = ["cdn.unretired.co.kr"]
  comment = "CDN for video streaming"
  enabled = true

  # Origin 1: Dev HLS
  origin {
    domain_name              = var.s3_bucket_domain_names.unretired_dev_abs
    origin_id                = "unretired-dev-abs.s3.ap-northeast-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.dev_abs.id
  }

  # Origin 2: Prod HLS
  origin {
    domain_name              = var.s3_bucket_domain_names.unretired_prod_abs
    origin_id                = "unretired-prod-abs.s3.ap-northeast-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.prod_abs.id
  }

  # Origin 3: Dev Origin
  origin {
    domain_name              = var.s3_bucket_domain_names.unretired_dev_origin
    origin_id                = "unretired-dev-origin.s3.ap-northeast-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.dev_origin.id
  }

  # Default Cache Behavior
  default_cache_behavior {
    target_origin_id         = "unretired-dev-origin.s3.ap-northeast-2.amazonaws.com"
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # Managed-CachingOptimized
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"  # Managed-CORS-S3Origin
    response_headers_policy_id = "eaab4381-ed33-4a86-88ca-d9558dc6cd63"  # Managed-CORS-with-preflight-and-SecurityHeadersPolicy

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
  }

  # Cache Behavior 1: Test HLS
  ordered_cache_behavior {
    path_pattern             = "/hls/test/*"
    target_origin_id         = "unretired-dev-abs.s3.ap-northeast-2.amazonaws.com"
    viewer_protocol_policy   = "https-only"
    compress                 = true
    cache_policy_id          = "1685b205-20ce-410f-b913-a4479e0871d1"  # Managed-Elemental-MediaPackage
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"  # Managed-CORS-S3Origin
    response_headers_policy_id = "9bc73fb2-aadd-499a-a1e5-daac4986e717"  # Managed-CORS-and-SecurityHeadersPolicy

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    trusted_key_groups = ["18a2fd97-1b81-49b9-8cb9-363c6d22f143"]
  }

  # Cache Behavior 2: Production HLS
  ordered_cache_behavior {
    path_pattern             = "/hls/*"
    target_origin_id         = "unretired-prod-abs.s3.ap-northeast-2.amazonaws.com"
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = "1685b205-20ce-410f-b913-a4479e0871d1"  # Managed-Elemental-MediaPackage
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"  # Managed-CORS-S3Origin
    response_headers_policy_id = "2ad0107a-0c2a-4f3e-89f3-12c1c27a8e52"  # Managed-SecurityHeadersPolicy

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    trusted_key_groups = ["18a2fd97-1b81-49b9-8cb9-363c6d22f143"]
  }

  # Cache Behavior 3: API
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "unretired-prod-abs.s3.ap-northeast-2.amazonaws.com"
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = "1685b205-20ce-410f-b913-a4479e0871d1"  # Managed-Elemental-MediaPackage
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"  # Managed-CORS-S3Origin
    response_headers_policy_id = "2ad0107a-0c2a-4f3e-89f3-12c1c27a8e52"  # Managed-SecurityHeadersPolicy

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    trusted_key_groups = ["18a2fd97-1b81-49b9-8cb9-363c6d22f143"]
  }

  # SSL Certificate
  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn_cdn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Geographic Restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Price Class
  price_class = "PriceClass_200"

  tags = {
    Name = "cdn-unretired"
  }
}

# CloudFront Distribution 2: Frontend (ERKSR0A3VNT7I)
resource "aws_cloudfront_distribution" "frontend" {
  aliases = ["www.unretired.co.kr"]
  comment = "Frontend distribution"
  enabled = true

  origin {
    domain_name              = var.s3_bucket_domain_names.front_dev_unretired
    origin_id                = "front-dev-unretired.s3.ap-northeast-2.amazonaws.com"
    origin_access_control_id = aws_cloudfront_origin_access_control.front_dev.id
  }

  default_cache_behavior {
    target_origin_id       = "front-dev-unretired.s3.ap-northeast-2.amazonaws.com"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimizedForUncompressedObjects

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
  }

  # Custom Error Response for SPA
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn_frontend
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_All"

  tags = {
    Name = "frontend-unretired"
  }
}

# CloudFront Distribution 3: Dev Frontend (E1G6ST1NAV08MO)
resource "aws_cloudfront_distribution" "dev_frontend" {
  aliases = ["front.dev.unretired.co.kr"]
  comment = "front.dev.unretired.co.kr"
  enabled = true

  origin {
    domain_name              = var.s3_bucket_domain_names.fe_dev_unretired
    origin_id                = "fe-dev-unretired.s3.ap-northeast-2.amazonaws.com-me6wpmuw1wv"
    origin_access_control_id = aws_cloudfront_origin_access_control.fe_dev.id
  }

  default_cache_behavior {
    target_origin_id       = "fe-dev-unretired.s3.ap-northeast-2.amazonaws.com-me6wpmuw1wv"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimizedForUncompressedObjects

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
  }

  # Custom Error Response for SPA
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn_frontend
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_All"

  tags = {
    Name = "dev-frontend-unretired"
  }
}
