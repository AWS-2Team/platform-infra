variable "name" {
  type        = string
  description = "리소스 이름 prefix. `<project>-<env>` 형식"
}

variable "region" {
  type        = string
  description = "AWS 리전. AZ 이름을 `<region><suffix>` 로 사용"
}

variable "cidr" {
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

variable "db_subnets" {
  type        = map(string)
  description = "DB subnet. key = AZ suffix, value = subnet CIDR"
}

variable "bastion_private_ip" {
  type        = string
  description = "NACL에서 bastion만 허용하기 위한 고정 private IP"
}
