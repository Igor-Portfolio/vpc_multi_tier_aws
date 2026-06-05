# Vpcs e subnets 



resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "multi-tier-VPC"
    }
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
        Name = subnet-private1~2
    }
}



resource "aws_subnet" "appication_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 0)
    availability_zone = data.availability_zone.names[0]
    tags = {
        Name = subnet-app1
    }
}

resource "aws_subnet" "appication_2" {
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

