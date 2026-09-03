data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket       = var.ecr_state_bucket
    key          = var.ecr_state_key
    region       = var.ecr_state_region
    profile      = var.aws_profile
    use_lockfile = true
    encrypt      = true
  }
}
