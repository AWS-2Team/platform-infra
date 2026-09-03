variable "name" {
  type        = string
  description = "리소스 이름 prefix. `<project>-<env>` 형식"
}

variable "oidc_thumbprints" {
  type        = list(string)
  description = "OIDC 공급자 인증서 지문 목록"
}

variable "roles" {
  type = map(object({
    subjects    = list(string)
    policy_arns = optional(list(string), [])
  }))
  description = "GitHub Actions 역할. key = 앱 이름. 역할 이름은 <name>-github-actions-<key> 로 조립"
}
