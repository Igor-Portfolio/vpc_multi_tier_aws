# Ec2 

resource "aws_instance" "application_python" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3_micro"
    subnet_id = aws_subnet.private1.id
    security_groups_ids = aws_security_group.ec2.id
    associate_public_ip_address = false 
}