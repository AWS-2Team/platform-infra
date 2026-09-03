output "repository_names" {
  description = "ECR repository names by image type."
  value       = { for name, repo in module.ecr : name => repo.repository_name }
}

output "repository_urls" {
  description = "ECR repository URLs by image type."
  value       = { for name, repo in module.ecr : name => repo.repository_url }
}

output "repository_arns" {
  description = "ECR repository ARNs by image type."
  value       = { for name, repo in module.ecr : name => repo.repository_arn }
}
