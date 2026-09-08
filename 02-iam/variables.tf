variable "region" {
  type        = string
  description = "AWS 리전"
}

variable "aws_profile" {
  type        = string
  description = "AWS 프로필 이름"
}

variable "aws_account_id" {
  type        = string
  description = "AWS 계정 ID"
}

variable "project" {
  type        = string
  description = "프로젝트 식별자"
}

variable "env" {
  type        = string
  description = "환경 이름"
}

variable "oidc_url" {
  type        = string
  description = "OIDC 공급자 URL"
}

variable "oidc_client_ids" {
  type        = list(string)
  description = "OIDC audience 목록"
}

variable "oidc_thumbprints" {
  type        = list(string)
  description = "OIDC 인증서 지문 목록"
}

variable "github_actions_roles" {
  type = map(object({
    subjects            = list(string)
    ecr_repository_keys = optional(list(string), [])
  }))
  description = "GitHub Actions 역할"
}

variable "ecr_state_bucket" {
  type        = string
  description = "ecr 상태 버킷"
}

variable "ecr_state_key" {
  type        = string
  description = "ecr 상태 키"
}

variable "ecr_state_region" {
  type        = string
  description = "ecr 상태 리전"
}
