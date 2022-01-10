output "vpc_id" {
  value = aws_vpc.spark_vpc.id
}

output "private_subnets_ids" {
  value = [for subnet in aws_subnet.private_subnets : subnet.id]
}

output "public_subnets_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_subnets_group" {
  value = aws_db_subnet_group.private_subnets_group.name
}
