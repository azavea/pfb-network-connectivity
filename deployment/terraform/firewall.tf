#
# Bastion security group resources
#
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_external_access_cidr_block]
  security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "bastion_http_egress" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "bastion_https_egress" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "bastion_postgresql_egress" {
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.vpc.bastion_security_group_id
  source_security_group_id = module.database.database_security_group_id
}

#
# RDS security group resources
#
resource "aws_security_group_rule" "postgresql_bastion_ingress" {
  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "postgresql_bastion_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "postgresql_app_container_instance_ingress" {
  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = aws_security_group.app_container_instance.id
}

resource "aws_security_group_rule" "postgresql_app_container_instance_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = aws_security_group.app_container_instance.id
}

resource "aws_security_group_rule" "postgresql_batch_container_instance_ingress" {
  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = aws_security_group.batch_container_instance.id
}

resource "aws_security_group_rule" "postgresql_batch_container_instance_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = module.database.database_security_group_id
  source_security_group_id = aws_security_group.batch_container_instance.id
}

#
# API ALB security group resources
#
resource "aws_security_group_rule" "alb_pfb_app_http_ingress" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.pfb_app_alb_ingress_cidr_block

  security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "alb_pfb_app_https_ingress" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.pfb_app_alb_ingress_cidr_block

  security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "alb_pfb_app_nat_http_ingress" {
  count = length(var.vpc_private_subnet_cidr_blocks)

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["${element(module.vpc.nat_gateway_ips, count.index)}/32"]

  security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "alb_pfb_app_nat_https_ingress" {
  count = length(var.vpc_private_subnet_cidr_blocks)

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${element(module.vpc.nat_gateway_ips, count.index)}/32"]

  security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "alb_pfb_app_container_instance_all_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  security_group_id        = aws_security_group.pfb_app_alb.id
  source_security_group_id = aws_security_group.app_container_instance.id
}

#
# App Container Instance security group resources
#
resource "aws_security_group_rule" "container_instance_http_egress" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app_container_instance.id
}

resource "aws_security_group_rule" "container_instance_https_egress" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app_container_instance.id
}

resource "aws_security_group_rule" "container_instance_postgresql_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = aws_security_group.app_container_instance.id
  source_security_group_id = module.database.database_security_group_id
}

resource "aws_security_group_rule" "container_instance_bastion_ssh_ingress" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = aws_security_group.app_container_instance.id
  source_security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "container_instance_alb_pfb_app_all_ingress" {
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  security_group_id        = aws_security_group.app_container_instance.id
  source_security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "container_instance_alb_pfb_app_all_egress" {
  type      = "egress"
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"

  security_group_id        = aws_security_group.app_container_instance.id
  source_security_group_id = aws_security_group.pfb_app_alb.id
}

resource "aws_security_group_rule" "container_instance_papertrail_egress" {
  type        = "egress"
  from_port   = var.papertrail_port
  to_port     = var.papertrail_port
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.app_container_instance.id
}

#
# Batch Container Instance security group resources
#
resource "aws_security_group_rule" "batch_container_instance_http_egress" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.batch_container_instance.id
}

resource "aws_security_group_rule" "batch_container_instance_https_egress" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.batch_container_instance.id
}

resource "aws_security_group_rule" "batch_container_instance_postgresql_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  security_group_id        = aws_security_group.batch_container_instance.id
  source_security_group_id = module.database.database_security_group_id
}

resource "aws_security_group_rule" "batch_container_instance_bastion_ssh_ingress" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"

  security_group_id        = aws_security_group.batch_container_instance.id
  source_security_group_id = module.vpc.bastion_security_group_id
}

