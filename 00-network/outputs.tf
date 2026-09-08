output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "eks_security_group_id" {
  value = module.vpc.eks_security_group_id
}

output "bastion_security_group_id" {
  value = module.vpc.bastion_security_group_id
}

output "bastion_instance_id" {
  value = module.vpc.bastion_instance_id
}

output "bastion_role_arn" {
  value = module.vpc.bastion_role_arn
}

output "bastion_public_ip" {
  value = module.vpc.bastion_public_ip
}

output "region" {
  value = var.region
}
