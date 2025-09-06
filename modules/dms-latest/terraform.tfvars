aws_profile        = "target"
source_aws_profile = "source"

src_db_identifier = "unretired-rds"
src_db_endpoint   = "unretired-rds.c5o64ekyqojn.ap-northeast-2.rds.amazonaws.com"

tgt_db_identifier = "unretired-rds-migrated"

private_subnet_ids = [
  "subnet-0037e9d97946113ca",
  "subnet-0cae48e47489025e0"
]

source_db_security_group_id = "sg-01297719a0b1000e7"
target_db_security_group_ids = ["sg-04f8aecbd6d94c93c"]

src_db_name     = "unretired_dev"
src_db_username = "admin"
src_db_password = "l3fZ2IzgkECFKad5RYqV"

dms_security_group_ids = ["sg-0787c8d952db45722"]

target_aws_account_id = "461814717327"
tgt_db_new_password = "l3fZ2IzgkECFKad5RYqV"