# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name           = var.project_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

# S3 Module
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name             = var.project_name
  vpc_id                   = module.vpc.vpc_id
  public_subnet_ids        = module.vpc.public_subnet_ids
  private_subnet_ids       = module.vpc.private_subnet_ids
  private_route_table_ids  = module.vpc.private_route_table_ids
  key_name                 = var.key_name

  # Security Groups (실제 보안 그룹에 맞게 수정)
  nat_instance_sg_id = module.vpc.nat_instance_sg_id
  bastion_sg_id      = module.vpc.bastion_sg_id
  bastion_tg_sg_id   = module.vpc.bastion_tg_sg_id
  ec2_rds_sg_id      = module.vpc.ec2_rds_1_sg_id
  rds_ec2_sg_id      = module.vpc.rds_ec2_1_sg_id
  alb_sg_id          = module.vpc.launch_wizard_sg_id  # ALB는 launch-wizard-1 보안 그룹 사용
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [
    module.vpc.rds_main_sg_id,
    module.vpc.rds_ec2_1_sg_id,
    module.vpc.rds_ec2_2_sg_id
  ]
  
  db_username = var.db_username
  db_password = var.db_password
}

# CloudFront Module
module "cloudfront" {
  source = "./modules/cloudfront"

  project_name = var.project_name
  
  s3_bucket_domain_names = {
    unretired_dev_abs    = module.s3.bucket_domain_names.unretired_dev_abs
    unretired_prod_abs   = module.s3.bucket_domain_names.unretired_prod_abs
    unretired_dev_origin = module.s3.bucket_domain_names.unretired_dev_origin
    front_dev_unretired  = module.s3.bucket_domain_names.front_dev_unretired
    fe_dev_unretired     = module.s3.bucket_domain_names.fe_dev_unretired
  }
}

# Lambda Module
module "lambda" {
  source = "./modules/lambda"

  project_name = var.project_name
  aws_region   = var.aws_region
  
  s3_bucket_names = {
    unretired_dev_mp4    = module.s3.bucket_names.unretired_dev_mp4
    unretired_dev_abs    = module.s3.bucket_names.unretired_dev_abs
    unretired_prod_abs   = module.s3.bucket_names.unretired_prod_abs
    unretired_dev_origin = module.s3.bucket_names.unretired_dev_origin
  }
  
  s3_bucket_arns = {
    unretired_dev_mp4    = module.s3.bucket_arns.unretired_dev_mp4
    unretired_dev_abs    = module.s3.bucket_arns.unretired_dev_abs
    unretired_prod_abs   = module.s3.bucket_arns.unretired_prod_abs
    unretired_dev_origin = module.s3.bucket_arns.unretired_dev_origin
  }
}

# WAF Module
module "waf" {
  source = "./modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.ec2.alb_arn
}

# Route53 Module
module "route53" {
  source = "./modules/route53"

  domain_name = var.domain_name
  
  # ALB DNS
  alb_dns_name = module.ec2.alb_dns_name
  alb_zone_id  = module.ec2.alb_zone_id
  
  # CloudFront DNS
  cloudfront_cdn_domain_name          = module.cloudfront.cdn_domain_name
  cloudfront_frontend_domain_name     = module.cloudfront.frontend_domain_name
  cloudfront_dev_frontend_domain_name = module.cloudfront.dev_frontend_domain_name
}
