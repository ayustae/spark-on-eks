# Terraform configuration
terraform {
  backend "s3" {
    encrypt = true
  }
}

# AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create the network infrastructure
module "vpc" {
  source = "./vpc/"
  # Variables
  network_ip   = var.vpc_network_ip
  selected_azs = var.amount_of_azs
  global_tags  = var.tags
}

module "cluster" {
  source = "./cluster/"
  # Variables
  vpc_id              = module.vpc.vpc_id
  public_subnets_ids  = module.vpc.public_subnets_ids
  private_subnets_ids = module.vpc.private_subnets_ids
  eks_service_cidr    = var.eks_cidr_range
  node_group_min      = var.eks_node_group_min
  node_group_max      = var.eks_node_group_max
  node_group_desired  = var.eks_node_group_desired
  instance_type       = var.eks_node_group_instance_type
  global_tags         = var.tags
}
