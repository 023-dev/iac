terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project = var.project_name
      Environment = var.environment
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias   = "source"
  region  = var.aws_region
  profile = var.source_aws_profile
}

resource "aws_security_group_rule" "allow_dms_inbound" {
  provider = aws.source

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.source_db_security_group_id
  description       = "Allow inbound traffic from DMS for migration"
}