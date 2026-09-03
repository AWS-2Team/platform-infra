locals {
  name_prefix = "${var.project}-${var.env}"
}

module "ecr" {
  for_each = var.ecr_repository_keys
  source   = "../modules/ecr"

  name                 = "${local.name_prefix}-${each.key}"
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
}
