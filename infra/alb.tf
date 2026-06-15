resource "aws_lb" "app_lb" {
    name = var.lb_name
    load_balancer_type = "application"
    internal = false
    security_groups = 
    subnets = 

}


resource "aws_lb_target_group" "application"{
    name = "backend"

}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  
}