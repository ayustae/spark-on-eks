# AWS Variables
variable "vpc_id" {
  description = "The id of the AWS VPC to be used."
  type        = string
}

variable "region" {
  description = "The AWS Region where the infrastructure is being deployed."
  type        = string
}

variable "global_tags" {
  description = "The tags to be applied to all AWS resources created."
  type        = map(string)
}

# Airflow DB variables

variable "db_subnet_group" {
  description = "The name fo the DB Subnet group to be used when deploying DBs."
  type        = string
}

variable "db_size" {
  description = "Size of the Airflow DB storage (in GB)."
  type        = number
}

variable "db_instance_type" {
  description = "Instance type of the Airflow DB."
  type        = string
}

variable "db_username" {
  description = "Airflow DB administrator username."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Airflow DB administrator password."
  type        = string
  sensitive   = true
}

# IAM elements
variable "nodes_security_group_id" {
  description = "Id of the Security Group used by the EKS nodes."
  type        = string
}

variable "nodes_role_name" {
  description = "Name of the role attached to the EKS nodes."
  type        = string
}
