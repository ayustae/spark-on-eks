# Create a public subnet on each selected Availability Zone
resource "aws_subnet" "public_subnets" {
  count                   = var.selected_azs
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.spark_vpc.id
  availability_zone       = random_shuffle.azs.result[count.index]
  cidr_block              = join("/", [join(".", [var.network_ip, 10 + count.index, "0"]), "24"])

  tags = merge(
    {
      Name  = "Spark Public Subnet #${count.index + 1}"
      Scope = "Public"
      AZ    = random_shuffle.azs.result[count.index]
    },
    var.global_tags
  )
}

# Reserve IP addresses for the NAT Gateways
resource "aws_eip" "nat_ips" {
  count = var.selected_azs
  vpc   = aws_vpc.spark_vpc.id

  tags = merge(
    {
      Name = "Spark NAT Gateway IP #${count.index + 1}"
    },
    var.global_tags
  )

  depends_on = [aws_internet_gateway.spark_igw]
}

# Create a NAT Gateway on each public subnet (for High Availability)
resource "aws_nat_gateway" "nat_gateways" {
  count         = var.selected_azs
  allocation_id = element(aws_eip.nat_ips.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnets.*.id, count.index)

  tags = merge(
    {
      Name = "Spark NAT Gateway #${count.index + 1}"
      AZ   = random_shuffle.azs.result[count.index]
    },
    var.global_tags
  )
}

# Create a route table for the public subnets
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.spark_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.spark_igw.id
  }

  tags = merge(
    {
      Name = "Spark Public Subnet Route table"
    },
    var.global_tags
  )

  depends_on = [aws_internet_gateway.spark_igw]
}

# Associate the public route table to the public subnets
resource "aws_route_table_association" "public_route_assoc" {
  count          = var.selected_azs
  route_table_id = aws_route_table.public_route.id
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
}
