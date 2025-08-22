output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = aws_route_table.private[*].id
}

output "availability_zones" {
  description = "Availability zones"
  value       = var.availability_zones
}

# Security Group Outputs - 실제 보안 그룹에 맞게 수정
output "nat_instance_sg_id" {
  description = "NAT Instance Security Group ID"
  value       = aws_security_group.nat_instance.id
}

output "bastion_sg_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}

output "bastion_tg_sg_id" {
  description = "Bastion Target Group Security Group ID"
  value       = aws_security_group.bastion_tg.id
}

output "ec2_rds_1_sg_id" {
  description = "EC2 to RDS Security Group 1 ID"
  value       = aws_security_group.ec2_rds_1.id
}

output "rds_ec2_1_sg_id" {
  description = "RDS from EC2 Security Group 1 ID"
  value       = aws_security_group.rds_ec2_1.id
}

output "ec2_rds_2_sg_id" {
  description = "EC2 to RDS Security Group 2 ID"
  value       = aws_security_group.ec2_rds_2.id
}

output "rds_ec2_2_sg_id" {
  description = "RDS from EC2 Security Group 2 ID"
  value       = aws_security_group.rds_ec2_2.id
}

output "rds_main_sg_id" {
  description = "RDS Main Security Group ID"
  value       = aws_security_group.rds_main.id
}

output "launch_wizard_sg_id" {
  description = "Launch Wizard Security Group ID"
  value       = aws_security_group.launch_wizard.id
}
