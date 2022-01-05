variable "global_tags" {
  description = "Tags to be assigned to all resources."
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC Id."
  type        = string
}

variable "public_subnets_ids" {
  description = "List of ids of the public subnets."
  type        = list(string)
}

variable "private_subnets_ids" {
  description = "List of ids of the private subnets."
  type        = list(string)
}

variable "eks_service_cidr" {
  description = "CIDR block to assign IPs to services of the EKS cluster."
  type        = string
}

variable "node_group_min" {
  description = "Minimum number of worker nodes."
  type        = number
}

variable "node_group_max" {
  description = "Maximum number of worker nodes."
  type        = number
}

variable "node_group_desired" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "instance_type" {
  description = "Instance type of the EKS nodes."
  type        = string
}
