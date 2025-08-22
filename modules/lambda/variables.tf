variable "project_name" {
  description = "Project name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "s3_bucket_names" {
  description = "S3 bucket names"
  type = object({
    unretired_dev_mp4    = string
    unretired_dev_abs    = string
    unretired_prod_abs   = string
    unretired_dev_origin = string
  })
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs"
  type = object({
    unretired_dev_mp4    = string
    unretired_dev_abs    = string
    unretired_prod_abs   = string
    unretired_dev_origin = string
  })
}
