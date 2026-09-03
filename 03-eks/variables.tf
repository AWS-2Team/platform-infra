variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
}

variable "project_name" {
  description = "Name prefix for EKS resources."
  type        = string
  default     = "petclinic-dev"
}

variable "tags" {
  description = "Extra tags applied to all supported resources."
  type        = map(string)
  default     = {}
}

variable "network_state_bucket" {
  description = "S3 bucket containing the network Terraform state."
  type        = string
}

variable "network_state_key" {
  description = "S3 key for the network Terraform state."
  type        = string
}

variable "network_state_region" {
  description = "AWS region of the network Terraform state bucket."
  type        = string
  default     = "ap-northeast-2"
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.36"
}

variable "eks_endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable from the internet."
  type        = bool
  default     = true
}

variable "eks_endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "eks_authentication_mode" {
  description = "EKS cluster authentication mode."
  type        = string
  default     = "API_AND_CONFIG_MAP"
}

variable "eks_node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_capacity_type" {
  description = "EKS node capacity type: ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_disk_size" {
  description = "Root volume size in GiB for worker nodes."
  type        = number
  default     = 20
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 2
}


