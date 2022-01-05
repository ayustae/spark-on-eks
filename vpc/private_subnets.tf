# Create a private subnet on each selected Availability Zone
resource "aws_subnet" "private_subnets" {
  count             = var.selected_azs
  vpc_id            = aws_vpc.spark_vpc.id
  availability_zone = random_shuffle.azs.result[count.index]
  cidr_block        = join("/", [join(".", [var.network_ip, 20 + count.index, "0"]), "24"])

  tags = merge(
    {
      Name                                      = "Spark Private Subnet #${count.index + 1}"
      Scope                                     = "Private"
      AZ                                        = random_shuffle.azs.result[count.index]
      "kubernetes.io/cluster/spark_k8s_cluster" = "shared"
    },
    var.global_tags
  )
}

# Create route tables for the private subnets
resource "aws_route_table" "private_routes" {
  count  = var.selected_azs
  vpc_id = aws_vpc.spark_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.nat_gateways.*.id, count.index)
  }

  tags = merge(
    {
      Name = "Spark Private Subnet #${count.index + 1} Route Table"
    },
    var.global_tags
  )

  depends_on = [aws_internet_gateway.spark_igw]
}

# Associate the public route table to the public subnets
resource "aws_route_table_association" "private_route_assoc" {
  count          = var.selected_azs
  route_table_id = element(aws_route_table.private_routes.*.id, count.index)
  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
}
