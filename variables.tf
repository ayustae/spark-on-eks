# Global variable
variable "tags" {
  description = "Tags to be used on all resources."
  type        = map(string)
  default = {
    Project = "Spark on k8s"
  }
}

variable "aws_region" {
  description = "AWS Region to use in the deployment."
  type        = string
  default     = "us-east-1"
}

# VPC definition variable
variable "vpc_network_ip" {
  description = "Network IP address for the VPC (only network octets)."
  type        = string
  default     = "10.0"
}

variable "eks_cidr_range" {
  description = "CIDR Range to be used by the EKS services."
  type        = string
  default     = "10.1.0.0/16"
}

variable "amount_of_azs" {
  description = "Amount of AZs to use."
  type        = number
  default     = 3
}

# EKS Scaling configuration
variable "eks_node_group_min" {
  description = "Minimum amount of worker nodes in the EKS cluster."
  type        = number
  default     = 2
}

variable "eks_node_group_max" {
  description = "Maximum amount of worker nodes in the EKS cluster."
  type        = number
  default     = 4
}

variable "eks_node_group_desired" {
  description = "Desired amount of worker nodes in the EKS cluster."
  type        = number
  default     = 3
}

# EKS nodes configuration
variable "eks_node_group_instance_type" {
  description = "Instance type to be used for the worker nodes in the EKS cluster."
  type        = string
  default     = "t3.medium"
}

variable "airflow_db_size" {
  description = "Size (in GiB) of the Airflow DB."
  type        = string
  default     = 30
}

variable "airflow_db_instance_type" {
  description = "Instance type of the Airflow DB."
  type        = string
  default     = "db.t3.micro"
}

variable "airflow_db_username" {
  description = "Airflow DB administrator username."
  type        = string
  default     = "airflow"
  sensitive   = true
}

variable "airflow_db_password" {
  description = "Airflow DB administrator password."
  type        = string
  default     = "Secret123!"
  sensitive   = true
}
