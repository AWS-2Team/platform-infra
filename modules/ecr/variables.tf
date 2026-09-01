variable "name" {
  description = "ECR repository name."
  type        = string
}

variable "image_tag_mutability" {
  description = "ECR tag mutability. Use IMMUTABLE for stricter production releases."
  type        = string
}

variable "force_delete" {
  description = "Delete the ECR repository even when images exist."
  type        = bool
}
