resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "devops_public_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "devops-public-subnet-1"
  }
  map_public_ip_on_launch = true
}

resource "aws_subnet" "devops_private_subnet" {
  vpc_id     = aws_vpc.devops_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "devops-private-subnet-1"
  }
  map_public_ip_on_launch = false
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "devops-nat-eip"
  }
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.devops_public_subnet.id
  tags = {
    Name = "devops-nat-gateway"
  }
  depends_on = [aws_internet_gateway.devops_igw]
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "devops-igw"
  }
}

resource "aws_route_table" "devops_public_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "devops-public-route-table"
  }
}

resource "aws_route_table" "devops_private_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  tags = {
    Name = "devops-private-route-table"
  }
}

resource "aws_route" "devops_public_route" {
  route_table_id         = aws_route_table.devops_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devops_igw.id
}

resource "aws_route" "devops_private_route" {
  route_table_id         = aws_route_table.devops_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "devops_public_rta" {
  subnet_id      = aws_subnet.devops_public_subnet.id
  route_table_id = aws_route_table.devops_public_rt.id
}

resource "aws_route_table_association" "devops_private_rta" {
  subnet_id      = aws_subnet.devops_private_subnet.id
  route_table_id = aws_route_table.devops_private_rt.id
}
