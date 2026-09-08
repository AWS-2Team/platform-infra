module "eks" {
  source = "../modules/eks"

  name                    = local.name
  cluster_version         = var.cluster_version
  subnet_ids              = concat(data.terraform_remote_state.network.outputs.public_subnet_ids, data.terraform_remote_state.network.outputs.private_subnet_ids)
  node_subnet_ids         = data.terraform_remote_state.network.outputs.private_subnet_ids
  security_group_ids      = [data.terraform_remote_state.network.outputs.eks_security_group_id]
  endpoint_public_access  = var.eks_endpoint_public_access
  endpoint_private_access = var.eks_endpoint_private_access
  authentication_mode     = var.eks_authentication_mode
  node_instance_types     = var.eks_node_instance_types
  node_capacity_type      = var.eks_node_capacity_type
  node_disk_size          = var.eks_node_disk_size
  node_min_size           = var.eks_node_min_size
  node_desired_size       = var.eks_node_desired_size
  node_max_size           = var.eks_node_max_size
}

resource "aws_eks_access_entry" "bastion" {
  cluster_name  = module.eks.cluster_name
  principal_arn = data.terraform_remote_state.network.outputs.bastion_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.bastion.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
