# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Instance Profile for SSM
data "aws_iam_instance_profile" "ssm" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}

# Bastion/NAT Instance
resource "aws_instance" "bastion" {
  ami                     = data.aws_ami.amazon_linux.id
  instance_type           = "t2.micro"
  key_name                = var.key_name
  subnet_id               = var.public_subnet_ids[1] # ap-northeast-2c
  vpc_security_group_ids  = [var.nat_instance_sg_id, var.bastion_sg_id]
  source_dest_check       = false
  iam_instance_profile    = data.aws_iam_instance_profile.ssm.name

  user_data = base64encode(templatefile("${path.module}/user_data/nat_instance.sh", {}))

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

# Elastic IP for Bastion
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

# Route for private subnets to use NAT instance
resource "aws_route" "private_nat" {
  count = 2

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.bastion.primary_network_interface_id
}

# Development Server
resource "aws_instance" "dev" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[1] # ap-northeast-2c
  vpc_security_group_ids = [var.bastion_tg_sg_id, var.ec2_rds_sg_id]
  iam_instance_profile   = data.aws_iam_instance_profile.ssm.name

  user_data = base64encode(templatefile("${path.module}/user_data/app_server.sh", {
    environment = "dev"
  }))

  tags = {
    Name = "${var.project_name}-dev"
  }
}

# Production Server
resource "aws_instance" "prod" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0] # ap-northeast-2a
  vpc_security_group_ids = [var.rds_ec2_sg_id, var.bastion_tg_sg_id]
  iam_instance_profile   = data.aws_iam_instance_profile.ssm.name

  user_data = base64encode(templatefile("${path.module}/user_data/app_server.sh", {
    environment = "prod"
  }))

  tags = {
    Name = "${var.project_name}-prod"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-prod-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "dev" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.dev.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "prod" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.prod.id
  port             = 80
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
