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

variable "private_subnet_ids" {
  description = "DMS 인스턴스를 배치할 Private Subnet IDs (B 계정)"
  type        = list(string)
  default     = [
    "subnet-0037e9d97946113ca",
    "subnet-0cae48e47489025e0"
  ]
}

variable "target_db_security_group_ids" {
  description = "Security Group IDs for the new target RDS instance"
  type        = list(string)
}

variable "dms_security_group_ids" {
  description = "DMS 인스턴스용 Security Group IDs (B 계정)"
  type        = list(string)
  default     = [
    "sg-0787c8d952db45722"
  ]
}

variable "source_db_security_group_id" {
  description = "The ID of the security group attached to the source RDS instance."
  type        = string
}

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

variable "tgt_db_name"     {
  type = string
  default = "unretired_dev"
}

variable "tgt_db_username" {
  type = string
  default = "admin"
}

variable "tgt_db_new_password" {
  type = string
}

variable "src_db_identifier" {
  type        = string
  default = "unretired-rds"
}

variable "tgt_db_identifier" {
  type        = string
  default = "unretired-rds"
}

variable "source_aws_profile" {
  type        = string
  default = "source"
}

variable "target_aws_account_id" {
  type        = string
}
