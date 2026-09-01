variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name. Null uses the default provider credential chain."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Name prefix for ECR resources."
  type        = string
  default     = "petclinic-dev"
}

variable "tags" {
  description = "Extra tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_name" {
  description = "ECR repository name."
  type        = string
  default     = "petclinic-dev-app"
}

variable "ecr_image_tag_mutability" {
  description = "ECR tag mutability. Use IMMUTABLE for stricter production releases."
  type        = string
  default     = "MUTABLE"
}

variable "ecr_force_delete" {
  description = "Delete the ECR repository even when images exist."
  type        = bool
  default     = true
}
