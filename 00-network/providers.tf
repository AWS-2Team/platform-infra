provider "aws" {
  region              = var.region
  profile             = var.aws_profile
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Environment = var.env
      Project     = var.project
      ManagedBy   = "Terraform"
    }
  }
}
