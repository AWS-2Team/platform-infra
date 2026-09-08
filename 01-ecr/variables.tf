variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

variable "project" {
  description = "프로젝트 식별자"
  type        = string
}

variable "env" {
  description = "환경 이름"
  type        = string
}

variable "tags" {
  description = "Extra tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "ecr_repository_keys" {
  description = "ECR repo 키. 이름은 <project>-<env>-<key>"
  type        = set(string)
}

variable "ecr_image_tag_mutability" {
  description = "ECR tag mutability."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_force_delete" {
  description = "Delete the ECR repository even when images exist."
  type        = bool
  default     = false
}
