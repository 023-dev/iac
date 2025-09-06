# AWS 계정 및 리전
source_aws_profile = "source"
target_aws_profile = "target"

# 네트워크 정보
source_vpc_id               = "vpc-0a0c212e320793d21"
target_vpc_id               = "vpc-0121b81c367e9380e"
source_rds_subnet_ids       = [
  "subnet-0d0ad21b8accdcd2a",
  "subnet-042cd2f47b92e94bf",
  "subnet-07c02cd7631aa1bf3",
  "subnet-0e794bef748206ac2"
]
target_dms_subnet_ids       = [
  "subnet-0037e9d97946113ca",
  "subnet-0cae48e47489025e0"
]
source_rds_sg_id            = "sg-01297719a0b1000e7"
target_dms_sg_id            = "sg-04f8aecbd6d94c93c"
target_rds_sg_id            = "sg-04f8aecbd6d94c93c"

# Source DB 정보
src_db_endpoint = "unretired-rds.c5o64ekyqojn.ap-northeast-2.rds.amazonaws.com"
src_db_name     = "unretired_dev"
src_db_username = "admin"
src_db_password = "l3fZ2IzgkECFKad5RYqV"

# Target DB 정보
tgt_db_name         = "unretired_dev"
tgt_db_username     = "admin"
tgt_db_new_password = "l3fZ2IzgkECFKad5RYqV"