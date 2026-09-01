output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data."
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID attached to managed nodes."
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL."
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "node_group_name" {
  description = "EKS managed node group name."
  value       = aws_eks_node_group.main.node_group_name
}
