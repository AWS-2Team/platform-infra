locals {
  oidc_host = replace(var.oidc_url, "https://", "")

  role_inline_policies = merge([
    for role_key, role in var.roles : {
      for policy_name, policy_json in role.inline_policies : "${role_key}::${policy_name}" => {
        role_key    = role_key
        policy_name = policy_name
        policy_json = policy_json
      }
    }
  ]...)
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = var.oidc_url
  client_id_list  = var.oidc_client_ids
  thumbprint_list = var.oidc_thumbprints
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name = "${var.name}-github-actions-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "${local.oidc_host}:aud" = var.oidc_client_ids[0] }
        StringLike   = { "${local.oidc_host}:sub" = each.value.subjects }
      }
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  for_each = local.role_inline_policies

  name   = each.value.policy_name
  role   = aws_iam_role.this[each.value.role_key].id
  policy = each.value.policy_json
}
