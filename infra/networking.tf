# Vpcs | subnets | Internet_gateway |  Route tables

# Vpcs

resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "multi-tier-VPC"
    }
}


# Subnets 

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 6)
    availability_zone = data.availability_zone.names[0]
}


resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 4)
    availability_zone = data.availability_zone.names[0]
    tags = {
        Name = subnet-private1
    }
}


resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 5)
    availability_zone = data.availability_zone.names[1]
    tags = {
        Name = subnet-private2
    }
}


resource "aws_subnet" "application_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
    availability_zone = data.availability_zone.names[0]
    tags = {
        Name = subnet-app1
    }
}

resource "aws_subnet" "application_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
    availability_zone = data.availability_zone.names[1]
    tags = {
        Name = subnet-app2
    }
}

resource "aws_subnet" "db1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 2)
    availability_zone = data.availability_zone.names[0]
    tags = {
        Name = subnet-db1
    }
}

resource "aws_subnet" "db2" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 3)
    availability_zone = data.availability_zone.names[1]
    tags = {
        Name = subnet-db2
    }
}


# Internet Internet_gateway

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
}


# Route tables 
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}



