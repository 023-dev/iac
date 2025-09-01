variable "aws_region" {
  default = "ap-northeast-2"
}

variable "aws_profile" {
  default = "target"
}

variable "project_name" {
  type = string
  default = "unretired-rds"
}

variable "environment" {
  default = "target"
}

# 인스턴스가 존재할 때
# variable "existing_dms_instance_arn" {
#   type    = string
#   default = "arn:aws:dms:ap-northeast-2:461814717327:rep:unretired-rds-dms-instance"
# }

# DMS 공통 설정
variable "private_subnet_ids" {
  description = "DMS 인스턴스를 배치할 Private Subnet IDs (B 계정)"
  type        = list(string)
  default     = [
    "subnet-0037e9d97946113ca",
    "subnet-0cae48e47489025e0"
  ]
}

variable "dms_security_group_ids" {
  description = "DMS 인스턴스용 Security Group IDs (B 계정)"
  type        = list(string)
  default     = [
    "sg-0787c8d952db45722"
  ]
}

# Source DB (기존 RDS)
variable "src_db_endpoint" {
  type    = string
  default = "unretired-rds.c5o64ekyqojn.ap-northeast-2.rds.amazonaws.com"
}

variable "src_db_name"     {
  type = string
  default = "unretired_dev"
}

variable "src_db_username" {
  type = string
  default = "admin"
}

variable "src_db_password" {
  type = string
  default = "l3fZ2IzgkECFKad5RYqV"
}

# Target DB (새로운 RDS)
variable "tgt_db_endpoint" {
  type = string
  default = "unretired-rds.ctckm0oiqitl.ap-northeast-2.rds.amazonaws.com"
}

variable "tgt_db_name"     {
  type = string
  default = "unretired_dev"
}

variable "tgt_db_username" {
  type = string
  default = "admin"
}

variable "tgt_db_password" {
  type = string
  default = "l3fZ2IzgkECFKad5RYqV"
}
