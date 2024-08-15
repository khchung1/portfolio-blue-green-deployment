
###=============Application Load Balancer=============###
#provision security group for application load balancer
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow inbound public traffic and outbound ASG"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Name = "security_grp_app_load_balancer"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_public" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "outbound_asg" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_lb" "prod" {
  name               = "production-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.prod.arn
  port              = "80"
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

