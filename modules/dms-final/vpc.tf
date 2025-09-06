resource "aws_vpc" "target_new" {
  provider = aws.target

  cidr_block           = "172.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-target-vpc"
  }
}

resource "aws_subnet" "target_private_a" {
  provider = aws.target

  vpc_id            = aws_vpc.target_new.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.project_name}-target-private-subnet-a"
  }
}

resource "aws_subnet" "target_private_b" {
  provider = aws.target

  vpc_id            = aws_vpc.target_new.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "${var.aws_region}c"

  tags = {
    Name = "${var.project_name}-target-private-subnet-b"
  }
}