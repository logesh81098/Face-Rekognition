#################################################################################################################################################
#                                                          VPC
#################################################################################################################################################
#Creating VPC to launch application on K8S cluster

resource "aws_vpc" "face-rekognition" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "Face-Rekognition-VPC"
    Project = "Face-Rekognition"
  }
}


#################################################################################################################################################
#                                                          Subnets
#################################################################################################################################################

resource "aws_subnet" "public-subnet-1" {
  vpc_id = aws_vpc.face-rekognition.id
  availability_zone = var.az1
  map_public_ip_on_launch = true
  cidr_block = var.public-subnet-1-cidr
  tags = {
    Name = "Face-Rekognition-Subnet1"
    Project = "Face-Rekognition"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id = aws_vpc.face-rekognition.id
  availability_zone = var.az2
  map_public_ip_on_launch = true
  cidr_block = var.public-subnet-2-cidr
  tags = {
    Name = "Face-Rekognition-Subnet2"
    Project = "Face-Rekognition"
  }
}

#################################################################################################################################################
#                                                          Internet Gateway
#################################################################################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.face-rekognition.id
  tags = {
    Name = "Face-Rekognition-IGW"
    Project = "Face-Rekognition"
  }
}

#################################################################################################################################################
#                                                            Route Table
################################################################################################################################################

resource "aws_route_table" "face-rekognition-rt" {
  vpc_id = aws_vpc.face-rekognition.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
    tags = {
    Name = "Face-Rekognition-Route Table"
    Project = "Face-Rekognition"
  }
}

#################################################################################################################################################
#                                                         Route Table Association
################################################################################################################################################

resource "aws_route_table_association" "rt1" {
  route_table_id = aws_route_table.face-rekognition-rt.id
  subnet_id = aws_subnet.public-subnet-1.id
}

resource "aws_route_table_association" "rt2" {
  route_table_id = aws_route_table.face-rekognition-rt.id
  subnet_id = aws_subnet.public-subnet-2.id
}