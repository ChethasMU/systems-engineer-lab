resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name    = "tf-deepdive-vpc"
  }
}

locals {
  subnets = {
    public-a  = { cidr = "10.1.1.0/24", az = "us-east-1a", public = true }
    public-b  = { cidr = "10.1.2.0/24", az = "us-east-1b", public = true }
    private-a = { cidr = "10.1.11.0/24", az = "us-east-1a", public = false }
    private-b = { cidr = "10.1.12.0/24", az = "us-east-1b", public = false }
  }
}

resource "aws_subnet" "this" {
  for_each                = local.subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public
  tags                    = { Name = "tf-${each.key}" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "tf-deepdive-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "tf-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = { for k, v in local.subnets : k => v if v.public }
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public.id
}
