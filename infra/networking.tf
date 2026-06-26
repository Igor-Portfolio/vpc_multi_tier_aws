# Vpcs | subnets | Internet_gateway |  Route tables

# Vpcs

resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "multi-tier-VPC"
    }
}


# Subnets 

resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 6)
    availability_zone = data.availability_zone.names[0]
}

resource "aws_subnet" "public_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 7)
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

resorce "aws_db_subnet_group" "db" {
    name = "app-db-subnet-group"
    subnet_ids = [
        aws_subnet.db1.id,
        aws_subnet.db2.id
    ]
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


# security_groups

resource "aws_security_group" "alb" {
    name = "alb_sg"
    description = "SG alb"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 443
        to_port = 443
        protocol =  "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        # Porta do backend em Python 
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
    }
}

resource "aws_security_group" "ec2" {
    name = "ec2_sg"
    description = "SG ec2"
    vpc_id = aws_vpc.main.id

    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
    }
    
    egress{
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
    }
}

resource "aws_security_group" "rds" {
    name = "rds_sg"
    description = "SG rds"~
    vpc_id = aws_vpc.main.id

    ingress{
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
    }
}

# application Load Balancer

resource "aws_lb" "app_lb" {
    name = var.lb_name
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}


resource "aws_lb_target_group" "app_lb" {
  name     = "app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group_attachment" "app_backend" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.application_python.id 
  port             = 8080                           
}





