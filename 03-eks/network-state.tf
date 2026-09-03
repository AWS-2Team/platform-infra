data "terraform_remote_state" "network" {
  backend = "s3"

  config = merge(
    {
      bucket       = var.network_state_bucket
      key          = var.network_state_key
      region       = var.network_state_region
      use_lockfile = true
      encrypt      = true
    },
    var.aws_profile == null ? {} : { profile = var.aws_profile }
  )
}
