resource "aws_vpc" "mian-Vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-1"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.mian-Vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "first public subnet "
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.mian-Vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "second public subnet "
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.mian-Vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_eip" "nat_gateway" {

  associate_with_private_ip = "10.0.0.5"
  depends_on                = [aws_internet_gateway.ig]
}
resource "aws_nat_gateway" "main-nat" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "gw NAT"
  }


}
resource "aws_route_table" "routing-table" {
  vpc_id = aws_vpc.mian-Vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-nat.id
    //gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}
resource "aws_route_table_association" "public-associate-table-1" { //assiciation part 
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.routing-table.id
}

resource "aws_route_table_association" "public-associate-table-2" { //assiciation part 
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.routing-table.id
}
resource "aws_security_group" "sec_group" {
  name   = "sec_group"
  vpc_id = aws_vpc.mian-Vpc.id
  /*ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }*/

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



}