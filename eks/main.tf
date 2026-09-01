module "eks" {
  source = "../modules/eks"

  name                    = local.name
  cluster_version         = var.cluster_version
  subnet_ids              = concat(data.terraform_remote_state.network.outputs.public_subnet_ids, data.terraform_remote_state.network.outputs.private_subnet_ids)
  node_subnet_ids         = data.terraform_remote_state.network.outputs.private_subnet_ids
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
