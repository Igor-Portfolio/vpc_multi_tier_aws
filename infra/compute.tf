# Ec2 

resource "aws_instance" "application_python" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.application.id
    security_groups_ids = aws_security_group.ec2.id
    associate_public_ip_address = false 
}


# db Instance 

resource "aws_db_instance" "db{
    allocated_storage = var.allocated_storage_db
    db_name = "app_db"
    engine = var.db_engine
    engine_version = var.version_engine_db
    instance_class = var.db_instance_class
    username = var.db_username
    password = var.db_password
    skip_final_snapshot = true
    db_subnet_group_name = aws_db_subnet_group.db.id
    security_group_ids = aws_security_group.db
}