variable "global_tags" {
  description = "Tags to be applied to all resources."
  type        = map(string)
}

variable "nodes_role_name" {
  description = "Name of the role used by the EKS worker nodes."
  type        = string
}
