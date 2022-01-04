variable "global_tags" {
  description = "Tags to be used on all resources."
  type        = map(string)
}

variable "network_ip" {
  description = "Network IP address (only network octets) for the VPC."
  type        = string
}

variable "selected_azs" {
  description = "Amount of Availaility Zones to use in the deployment."
  type        = number
}
