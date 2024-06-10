output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.igw.id
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.nat.id
}

