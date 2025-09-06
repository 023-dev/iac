data "aws_caller_identity" "source" {
  provider = aws.source
}

data "aws_caller_identity" "target" {
  provider = aws.target
}

data "aws_vpc" "source" {
  provider = aws.source
  id       = var.source_vpc_id
}

resource "aws_vpc_peering_connection" "this" {
  provider      = aws.target
  peer_owner_id = data.aws_caller_identity.source.account_id
  peer_vpc_id   = var.source_vpc_id
  vpc_id        = aws_vpc.target_new.id
  auto_accept   = false
  tags          = { Name = "dms-peering-${var.project_name}" }
}

resource "aws_vpc_peering_connection_accepter" "this" {
  provider                  = aws.source
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = true
  tags                      = { Name = "dms-peering-${var.project_name}" }
}

resource "aws_route" "target_to_source" {
  provider                  = aws.target
  route_table_id            = aws_vpc.target_new.main_route_table_id
  destination_cidr_block    = data.aws_vpc.source.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

data "aws_route_table" "source_main" {
  provider = aws.source
  vpc_id   = var.source_vpc_id
  filter {
    name   = "association.main"
    values = ["true"]
  }
}

resource "aws_route" "source_to_target" {
  provider                  = aws.source
  route_table_id            = data.aws_route_table.source_main.id
  destination_cidr_block    = aws_vpc.target_new.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_vpc_security_group_egress_rule" "dms_to_source_rds" {
  provider          = aws.target
  security_group_id = aws_security_group.dms.id # DMS 보안 그룹에 적용

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306
  cidr_ipv4   = data.aws_vpc.source.cidr_block
  description = "Allow DMS to connect to Source RDS"
}

resource "aws_vpc_security_group_ingress_rule" "source_rds_from_dms" {
  provider          = aws.source
  security_group_id = var.source_rds_sg_id

  ip_protocol = "tcp"
  from_port   = 3306
  to_port     = 3306
  cidr_ipv4   = aws_vpc.target_new.cidr_block
  description = "Allow DMS from Target Account VPC"
}

resource "aws_vpc_security_group_egress_rule" "dms_to_target_rds" {
  provider = aws.target
  security_group_id              = aws_security_group.dms.id

  ip_protocol                    = "tcp"
  from_port                      = 3306
  to_port                        = 3306
  referenced_security_group_id = aws_security_group.target_rds.id
  description                    = "Allow DMS to connect to Target RDS"
}

resource "aws_vpc_security_group_ingress_rule" "target_rds_from_dms" {
  provider = aws.target
  security_group_id        = aws_security_group.target_rds.id

  ip_protocol              = "tcp"
  from_port                = 3306
  to_port                  = 3306
  referenced_security_group_id = aws_security_group.dms.id
  description              = "Allow RDS to be connected from DMS"
}