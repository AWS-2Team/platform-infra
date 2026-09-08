variable "name" {
  type        = string
  description = "리소스 이름 prefix"
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

variable "roles" {
  type = map(object({
    subjects        = list(string)
    inline_policies = optional(map(string), {})
  }))
  description = "GitHub Actions 역할"
}
