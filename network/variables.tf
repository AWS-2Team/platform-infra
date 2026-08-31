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

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "public_subnets" {
  type        = map(string)
  description = "public subnet. key = AZ suffix, value = subnet CIDR"
}

variable "private_subnets" {
  type        = map(string)
  description = "private subnet. key = AZ suffix, value = subnet CIDR"
}
