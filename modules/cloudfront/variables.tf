variable "project_name" {
  description = "Project name"
  type        = string
}

variable "s3_bucket_domain_names" {
  description = "S3 bucket domain names"
  type = object({
    unretired_dev_abs    = string
    unretired_prod_abs   = string
    unretired_dev_origin = string
    front_dev_unretired  = string
    fe_dev_unretired     = string
  })
}

variable "acm_certificate_arn_cdn" {
  description = "ACM certificate ARN for CDN domain"
  type        = string
  default     = "arn:aws:acm:us-east-1:913524915414:certificate/ec208157-6ec6-47eb-a7b0-0af0919ee2aa"
}

variable "acm_certificate_arn_frontend" {
  description = "ACM certificate ARN for frontend domains"
  type        = string
  default     = "arn:aws:acm:us-east-1:913524915414:certificate/544fbd36-39d0-498c-a60c-a6ce51e62ea9"
}
