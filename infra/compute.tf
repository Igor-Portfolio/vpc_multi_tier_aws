# Ec2 

resource "aws_instance" "application_python" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3_micro"
    subnet_id = aws_subnet.private1.id
    security_groups_ids = aws_security_group.ec2.id
    associate_public_ip_address = false 
}


# db Instance 

resource "aws_db_instance" "db{
    allocated_storage = 1
    db_name = "app_db"
    engine = "postgres"
    engine_version = "15.15"
    instance_class = "db.t3.micro"
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.db.id
    security_group_ids = aws_security_group.db
}