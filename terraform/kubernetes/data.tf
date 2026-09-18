data "aws_vpc" "devops_vpc" {
  tags = {
    Name = "devops-vpc"
  }
}

data "aws_subnets" "devops_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.devops_vpc.id]
  }

  tags = {
    Name = "devops-private-subnet-*"
  }
}
