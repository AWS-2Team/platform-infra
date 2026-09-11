locals {
  name_prefix = "${var.project}-${var.env}"
}

module "vpc" {
  source = "../modules/vpc"

  name                = local.name_prefix
  region              = var.region
  cidr                = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_subnets     = var.private_subnets
  db_subnets          = var.db_subnets
  karpenter_discovery = var.karpenter_discovery
  bastion_private_ip  = var.bastion_private_ip
  bastion_ami_id      = var.bastion_ami_id
}
