# Vpcs e subnets 

resource "aws_vpc" "main"{
    cidr_block = "10.0.0.0/16"
    region = var.aws_region
    tags = {
        Name = "multi-tier-VPC"
    }
}


resource "aws_subnet" "appication_1" {
    vpc_id = aws_vpc.main.vpc_id
    cidr_block = "10.0.0.0/24
    availability_zone = "eu-south-2a"
    tags = {
        Name = subnet-app1
    }
}

resource "aws_subnet" "appication_2" {
    vpc_id = aws_vpc.main.vpc_id
    cidr_block = "10.0.1.0/24
    availability_zone = "eu-south-2b"
    tags = {
        Name = subnet-app2
    }
}

resource "aws_subnet" "db1" {
    vpc_id = aws_vpc.main.vpc_id
    cidr_block = "10.0.2.0/24
    availability_zone = "eu-south-2a"
    tags = {
        Name = subnet-db1
    }
}

resource "aws_subnet" "db2" {
    vpc_id = aws_vpc.main.vpc_id
    cidr_block = "10.0.3.0/24
    availability_zone = "eu-south-2a"
    tags = {
        Name = subnet-db2
    }
}

