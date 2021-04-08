provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "wp_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "wp_vpc"
  }
}
# Creating Public Subnet for Wordpress
resource "aws_subnet" "public_subnet1" {
  availability_zone = var.availability_zone1
  vpc_id     = aws_vpc.wp_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

 

  tags = {
    Name = "public_subnet"
  }
}
resource "aws_subnet" "public_subnet2" {
  availability_zone = var.availability_zone2
  vpc_id     = aws_vpc.wp_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

 

  tags = {
    Name = "public_subnet"
  }
}
#Creating private_subnet
resource "aws_subnet" "private_subnet1" {
  vpc_id     = aws_vpc.wp_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.availability_zone1
  
  tags = {
    Name = "private_subnet"
  }
}


resource "aws_subnet" "private_subnet2" {
  vpc_id     = aws_vpc.wp_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.availability_zone2
  
  tags = {
    Name = "private_subnet"
  }
}

#Create IGW
resource "aws_internet_gateway" "wp_igw" {
  vpc_id =  aws_vpc.wp_vpc.id

  tags = {
    Name = "wp_internet_gateway"
  }
}
#Route table public_subnet
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.wp_vpc.id
  tags = {
    Name = "public-rt"
  }
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.wp_igw.id
  }

}
#SUBNET ASSOCIATION
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rtb_public.id
}
resource "aws_route_table_association" "rta_subnet_public2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rtb_public.id
}

#NAT

resource "aws_eip" "nat1" {
  
  vpc      = true
}

resource "aws_eip" "nat2" {
  
  vpc      = true
}
resource "aws_nat_gateway" "natgw1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_subnet1.id
  

  tags = {
    Name = "gw NAT"
  }
}
resource "aws_nat_gateway" "natgw2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_subnet2.id
  

  tags = {
    Name = "gw NAT"
  }
}

#private rt
resource "aws_route_table" "rtb_private1" {
vpc_id = aws_vpc.wp_vpc.id
tags = {
    Name = "private-rt"
  }
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.natgw1.id
  }

}
#subnet ASSOCIATION
resource "aws_route_table_association" "rta_subnet_private" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.rtb_private1.id
}
#private rt2
resource "aws_route_table" "rtb_private2" {
vpc_id = aws_vpc.wp_vpc.id
tags = {
    Name = "private-rt"
  }
route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.natgw2.id
  }

}
#subnet ASSOCIATION
resource "aws_route_table_association" "rta_subnet_private2" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.rtb_private2.id
}



