# VPC module for setting up vpc
module "vpc" {
  source                     = "github.com/azavea/terraform-aws-vpc?ref=6.0.1"
  name                       = "pfb${var.environment}"
  region                     = var.aws_region
  key_name                   = var.aws_key_name
  cidr_block                 = var.vpc_cidr_block
  private_subnet_cidr_blocks = var.vpc_private_subnet_cidr_blocks
  public_subnet_cidr_blocks  = var.vpc_public_subnet_cidr_blocks
  availability_zones         = var.vpc_availibility_zones
  bastion_ami                = var.bastion_ami
  bastion_instance_type      = var.vpc_bastion_instance_type

  project     = var.project
  environment = var.environment
}

