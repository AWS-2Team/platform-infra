locals {
  name_prefix         = "${var.project}-${var.env}"
  ecr_repository_arns = data.terraform_remote_state.ecr.outputs.repository_arns

  roles = {
    for role_key, role in var.github_actions_roles : role_key => {
      subjects = role.subjects
      inline_policies = length(role.ecr_repository_keys) == 0 ? {} : {
        "ecr-push" = templatefile("${path.module}/ecr-push-policy.json.tpl", {
          repository_arns = jsonencode([for repo_key in role.ecr_repository_keys : local.ecr_repository_arns[repo_key]])
        })
      }
    }
  }
}

module "iam" {
  source = "../modules/iam"

  name             = local.name_prefix
  oidc_url         = var.oidc_url
  oidc_client_ids  = var.oidc_client_ids
  oidc_thumbprints = var.oidc_thumbprints
  roles            = local.roles
}
