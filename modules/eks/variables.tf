variable "name" {
  description = "Name prefix for EKS resources."
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the EKS control plane."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Private subnets for the EKS managed node group."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Additional security groups for the EKS control plane."
  type        = list(string)
  default     = []
}

variable "endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable from the internet."
  type        = bool
}

variable "endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
}

variable "authentication_mode" {
  description = "EKS cluster authentication mode."
  type        = string
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
}

variable "node_capacity_type" {
  description = "EKS node capacity type: ON_DEMAND or SPOT."
  type        = string
}

variable "node_disk_size" {
  description = "Root volume size in GiB for worker nodes."
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
}
