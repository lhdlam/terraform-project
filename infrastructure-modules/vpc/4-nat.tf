resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Name = "${var.env}-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.env}-nat"
  }
  
}