locals {
  name_prefix = "${var.project}-${var.env}"
}

module "iam" {
  source = "../modules/iam"

  name             = local.name_prefix
  oidc_thumbprints = var.oidc_thumbprints
  roles            = var.github_actions_roles
}
