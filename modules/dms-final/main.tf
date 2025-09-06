terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  alias   = "target"
  region  = var.aws_region
  profile = var.target_aws_profile
}

provider "aws" {
  alias   = "source"
  region  = var.aws_region
  profile = var.source_aws_profile
}