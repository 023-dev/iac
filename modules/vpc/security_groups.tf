# 실제 AWS 인프라에 맞는 보안 그룹 정의

# 1. NAT Instance Security Group (sg-063353eb24d716c15)
resource "aws_security_group" "nat_instance" {
  name        = "nat-instance"
  description = "nat instace for vpc unretired"
  vpc_id      = aws_vpc.main.id

  # Ingress rules - bastion-tg-sg에서 모든 트래픽 허용
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_tg.id]
  }

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "udp"
    security_groups = [aws_security_group.bastion_tg.id]
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.bastion_tg.id]
  }

  # Egress rules - 모든 외부 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-instance"
  }
}

# 2. Bastion Security Group (sg-0882b29082c48255b)
resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "bastion security group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# 3. Bastion Target Group Security Group (sg-06930983098cc34d2)
resource "aws_security_group" "bastion_tg" {
  name        = "bastion-tg-sg"
  description = "access ssh from bastion host"
  vpc_id      = aws_vpc.main.id

  # VPC 내부 모든 트래픽 허용
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Bastion에서 SSH 접근
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # 모든 외부 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-tg-sg"
  }
}

# 4. EC2 to RDS Security Group 1 (sg-074a9c34f5484c4e4)
resource "aws_security_group" "ec2_rds_1" {
  name        = "ec2-rds-1"
  description = "Security group attached to instances to securely connect to unretired-rds. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "Rule to allow connections to unretired-rds from any instances this security group is attached to"
  }

  tags = {
    Name = "ec2-rds-1"
  }
}

# 5. RDS from EC2 Security Group 1 (sg-0bc06d4b192937baa)
resource "aws_security_group" "rds_ec2_1" {
  name        = "rds-ec2-1"
  description = "Security group attached to unretired-rds to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "Rule to allow connections from EC2 instances with sg-074a9c34f5484c4e4 attached"
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    description     = "test icmp"
  }

  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
  }

  tags = {
    Name = "rds-ec2-1"
  }
}

# 6. EC2 to RDS Security Group 2 (sg-0b36c50214409f1da)
resource "aws_security_group" "ec2_rds_2" {
  name        = "ec2-rds-2"
  description = "Security group attached to instances to securely connect to unretired-rds. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "Rule to allow connections to unretired-rds from any instances this security group is attached to"
  }

  tags = {
    Name = "unretired-ecs-ec2-sg"
  }
}

# 7. RDS from EC2 Security Group 2 (sg-0cf43a110dd377a0b)
resource "aws_security_group" "rds_ec2_2" {
  name        = "rds-ec2-2"
  description = "Security group attached to unretired-rds to allow EC2 instances with specific security groups attached to connect to the database. Modification could lead to connection loss."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    description     = "Rule to allow connections from EC2 instances with sg-0b36c50214409f1da attached"
  }

  tags = {
    Name = "rds-ec2-2"
  }
}

# 8. RDS Security Group (sg-01297719a0b1000e7)
resource "aws_security_group" "rds_main" {
  name        = "rds-security-group"
  description = "Created by RDS management console"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_ec2_1.id]
  }

  # 외부 IP 접근 (개발용)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["121.134.241.197/32", "121.171.77.14/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Unretired-rds"
  }
}

# 9. Launch Wizard Security Group (sg-0ddcbea3e398c7a6c)
resource "aws_security_group" "launch_wizard" {
  name        = "launch-wizard-1"
  description = "launch-wizard-1 created 2025-02-08T10:47:49.320Z"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "launch-wizard-1"
  }
}

resource "aws_security_group_rule" "ec2_to_rds_1" {
  type                     = "egress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = aws_security_group.ec2_rds_1.id
  source_security_group_id = aws_security_group.rds_ec2_1.id
  description             = "Rule to allow connections to unretired-rds"
}

resource "aws_security_group_rule" "rds_from_ec2_1" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = aws_security_group.rds_ec2_1.id
  source_security_group_id = aws_security_group.ec2_rds_1.id
  description             = "Rule to allow connections from EC2 instances"
}

resource "aws_security_group_rule" "rds_icmp_from_ec2_1" {
  type                     = "ingress"
  from_port               = -1
  to_port                 = -1
  protocol                = "icmp"
  security_group_id       = aws_security_group.rds_ec2_1.id
  source_security_group_id = aws_security_group.ec2_rds_1.id
  description             = "test icmp"
}

resource "aws_security_group_rule" "rds_icmp_from_ec2_2" {
  type                     = "ingress"
  from_port               = -1
  to_port                 = -1
  protocol                = "icmp"
  security_group_id       = aws_security_group.rds_ec2_1.id
  source_security_group_id = aws_security_group.ec2_rds_2.id
}

resource "aws_security_group_rule" "ec2_to_rds_2" {
  type                     = "egress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = aws_security_group.ec2_rds_2.id
  source_security_group_id = aws_security_group.rds_ec2_2.id
  description             = "Rule to allow connections to unretired-rds"
}

resource "aws_security_group_rule" "rds_from_ec2_2" {
  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"
  security_group_id       = aws_security_group.rds_ec2_2.id
  source_security_group_id = aws_security_group.ec2_rds_2.id
  description             = "Rule to allow connections from EC2 instances"
}
