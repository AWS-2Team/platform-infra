module "ecr" {
  for_each = var.ecr_repository_names
  source   = "../modules/ecr"

  name                 = each.value
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete
}
