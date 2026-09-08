data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket       = var.network_state_bucket
    key          = var.network_state_key
    region       = var.network_state_region
    profile      = var.aws_profile
    use_lockfile = true
    encrypt      = true
  }
}
