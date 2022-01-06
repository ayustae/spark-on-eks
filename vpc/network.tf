# Create a custom VPC
resource "aws_vpc" "spark_vpc" {
  cidr_block           = join("/", [join(".", [var.network_ip, "0", "0"]), "16"])
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "Spark VPC"
    },
    var.global_tags
  )
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "spark_igw" {
  vpc_id = aws_vpc.spark_vpc.id

  tags = merge(
    {
      Name = "Spark VPC Internet Gateway"
    },
    var.global_tags
  )
}

# Get the available Availability Zones
data "aws_availability_zones" "avail_azs" {
  state         = "available"
  exclude_names = ["us-east-1e"]
}

# Select some random availability zones
resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.avail_azs.names
  result_count = var.selected_azs
}
