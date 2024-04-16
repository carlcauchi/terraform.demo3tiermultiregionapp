# Allocate Elastic IP. (This EIP will be used for the Nat-Gateway in the Public Subnet AZ1)
resource "aws_eip" "eip_for_nat_gateway_az1" {
  domain = "vpc"

  tags = {
    Name = "Nat Gateway AZ1 EIP"
  }
}

# Allocate Elastic IP. (This EIP will be used for the Nat-Gateway in the Public Subnet AZ2)
resource "aws_eip" "eip_for_nat_gateway_az2" {
  domain = "vpc"

  tags = {
    Name = "Nat Gateway AZ2 EIP"
  }
}

# Create Nat Gateway in Public Subnet AZ1
resource "aws_nat_gateway" "nat_gateway_az1" {
  allocation_id = aws_eip.eip_for_nat_gateway_az1.id
  subnet_id     = var.public_subnet_az1_id

  tags = {
    Name = "Nat Gateway AZ1"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency
  depends_on = [var.internet_gateway]
}

# Create Nat Gateway in Public Subnet AZ2
resource "aws_nat_gateway" "nat_gateway_az2" {
  allocation_id = aws_eip.eip_for_nat_gateway_az2.id
  subnet_id     = var.public_subnet_az2_id

  tags = {
    Name = "Nat Gateway AZ2"
  }

  # to ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [var.internet_gateway]
}

# Create Private Route Table AZ1 and add route through Nat Gateway AZ1
resource "aws_route_table" "private_route_table_az1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az1.id
  }

  tags = {
    Name = "Private Route Table AZ1"
  }
}

# Associate Private Subnet AZ1 with Private Route Table AZ1
resource "aws_route_table_association" "private_subnet_az1_route_table_az1_association" {
  subnet_id      = var.private_subnet_az1_id
  route_table_id = aws_route_table.private_route_table_az1.id
}

# Create Private Route Table AZ2 and add route through Nat Gateway AZ2
resource "aws_route_table" "private_route_table_az2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_az2.id
  }

  tags = {
    Name = "Private Route Table AZ2"
  }
}

# Associate Private Subnet AZ2 with Private Route Table AZ2
resource "aws_route_table_association" "private_subnet_az2_route_table_az2_association" {
  subnet_id      = var.private_subnet_az2_id
  route_table_id = aws_route_table.private_route_table_az2.id
}