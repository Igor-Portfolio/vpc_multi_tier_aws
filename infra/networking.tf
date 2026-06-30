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
    count = length(local.azs)
    cidr_block = local.public_cidrs[count.index]
    availability_zone = local.azs[count.index]
}

resource "aws_subnet" "application" {
    vpc_id = aws_vpc.main.id
    count = length(local.azs)
    cidr_block = local.private_cidrs[count.index]
    availability_zone = local.azs[count.index]
}

resource "aws_subnet" "db" {
    vpc_id = aws_vpc.main.id
    count = length(local.azs)
    cidr_block = local.db_cidrs[count.index]
    availability_zone = local.azs[count.index]
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
    count = length(aws_subnet.public)
    subnet_id = aws_subnet.public[count.index].id
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
    count = length(aws_subnet.public)
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.alb.id]
    subnets = aws_subnet.public[count.index].id
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





