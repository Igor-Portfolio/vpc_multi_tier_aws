resource "aws_db_instance" "db{
    allocated_storage = 1
    db_name = "app_db"
    engine = "postgres"
    engine_version = "
    instance_class = "db.t3.micro"
    username = "Igor"
    password = "Igor2000"
    parameter_group_name = 
    skip_final_snapshot = 
    db_subnet_group_name
    security_group_ids
}