output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.this.id
}

output "aws_nat_gateway" {
  value = aws_nat_gateway.this.id
}