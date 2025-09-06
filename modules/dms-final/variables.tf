# AWS 계정 및 리전
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}
variable "source_aws_profile" {
  description = "AWS CLI profile 소스 계정"
  type        = string
}
variable "target_aws_profile" {
  description = "AWS CLI profile 타겟 계정"
  type        = string
}

variable "environment" {
  default = "target"
}

# 프로젝트 정보
variable "project_name" {
  description = "A unique name for the project."
  type        = string
  default     = "unretired-rds"
}

variable "dms_security_group_ids" {
  description = "DMS 인스턴스용 Security Group IDs (B 계정)"
  type        = list(string)
  default     = [
    "sg-0787c8d952db45722"
  ]
}

# 네트워크 정보 (Source & Target)
variable "source_vpc_id" {
  description = "The ID of the VPC in the source account."
  type        = string
}
variable "target_vpc_id" {
  description = "The ID of the VPC in the target account."
  type        = string
}
variable "source_rds_subnet_ids" {
  description = "List of private subnet IDs where the source RDS is located."
  type        = list(string)
}
variable "target_dms_subnet_ids" {
  description = "List of private subnet IDs in the target account for DMS and new RDS."
  type        = list(string)
}
variable "source_rds_sg_id" {
  description = "The security group ID of the source RDS instance."
  type        = string
}
variable "target_dms_sg_id" {
  description = "The security group ID for the DMS replication instance in the target account."
  type        = string
}
variable "target_rds_sg_id" {
  description = "The security group ID for the new target RDS instance."
  type        = string
}

# Source DB 정보
variable "src_db_endpoint" {
  description = "The endpoint of the source RDS instance."
  type        = string
}
variable "src_db_name" {
  description = "The database name of the source RDS instance."
  type        = string
}
variable "src_db_username" {
  description = "The master username for the source RDS instance."
  type        = string
}
variable "src_db_password" {
  description = "The master password for the source RDS instance."
  type        = string
  sensitive   = true
}

# Target DB 정보
variable "tgt_db_identifier" {
  description = "The identifier for the new target RDS instance."
  type        = string
  default     = "unretired-rds-migrated"
}
variable "tgt_db_name" {
  description = "The database name for the new target RDS instance."
  type        = string
}
variable "tgt_db_username" {
  description = "The master username for the new target RDS instance."
  type        = string
}
variable "tgt_db_new_password" {
  description = "The new master password for the target RDS instance."
  type        = string
  sensitive   = true
}

# 완료된 테스크
variable "reuse_task_arn" {
  type = string
  default = "arn:aws:dms:ap-northeast-2:461814717327:task:MQK27QHT4RBZ5AOUBAVJ6PELCU"
}

variable "reload_token" {
  type    = string
  default = "v1"
}