output "oidc_provider_arn" {
  description = "GitHub OIDC 공급자 ARN."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "role_arns" {
  description = "역할 key 별 ARN."
  value       = { for k, r in aws_iam_role.this : k => r.arn }
}
