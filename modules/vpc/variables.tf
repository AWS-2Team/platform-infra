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

variable "karpenter_discovery" {
  type        = string
  description = "Karpenter discovery tag value for EKS private subnets"
}

variable "bastion_private_ip" {
  type        = string
  description = "NACL에서 bastion만 허용하기 위한 고정 private IP"
}

variable "bastion_ami_id" {
  type        = string
  description = "Bastion EC2 AMI ID"
  default     = "ami-00b5b2470beafd65f"
}
