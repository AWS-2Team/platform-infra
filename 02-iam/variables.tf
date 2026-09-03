variable "region" {
  type = string
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI 프로필 이름 (~/.aws/credentials 또는 config)"
}

variable "aws_account_id" {
  type        = string
  description = "허용된 AWS 계정 ID (12자리)"
}

variable "project" {
  type        = string
  description = "프로젝트 식별자. 태그와 리소스 이름 prefix 로 사용"
}

variable "env" {
  type        = string
  description = "환경 이름 (dev, stg, prod)"
}

# thumbprint 는 GitHub OIDC 공급자(token.actions.githubusercontent.com)의 TLS 인증서(CA)
# SHA-1 지문이다. AWS 가 토큰 검증 시 그 공급자의 HTTPS 인증서를 신뢰하는 데 쓰던 값.
# GitHub 처럼 잘 알려진 IdP 는 AWS 가 자체 신뢰 CA 로 검증해서 지금은 형식적이지만,
# 공급자를 만들 때 값이 필요하고 인증서 로테이션 시에도 GitHub OIDC 동작엔 영향이 없다.
variable "oidc_thumbprints" {
  type        = list(string)
  description = "GitHub OIDC 공급자 인증서 지문 목록"
  default     = ["ab9d0263244dd0326eb67015705a667e79cfe998"]
}

variable "github_actions_roles" {
  type = map(object({
    subjects    = list(string)
    policy_arns = optional(list(string), [])
  }))
  description = "GitHub Actions 역할. key = 앱 이름. 역할 이름은 <project>-<env>-github-actions-<key> 로 조립"
}
