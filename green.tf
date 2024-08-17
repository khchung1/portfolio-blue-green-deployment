###=========EC2 Instances===========###

resource "aws_security_group" "green" {
  name        = "green-sg"
  description = "Allow alb traffic to app"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]

  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_launch_template" "green" {
  name_prefix   = "blue"
  image_id      = data.aws_ami.ami_1.id
  instance_type = "t2.micro"
  user_data     = filebase64("${path.module}/init-green-script.sh")
  key_name      = "KH-key"


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.blue.id}"]
  }

  lifecycle {
    create_before_destroy = true
  }

}

###=============Auto Scaling Group (ASG)=============###
resource "aws_autoscaling_group" "green" {
  name                = "asg-green"
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  force_delete        = true
  vpc_zone_identifier = [for subnet in data.aws_subnets.private.ids : subnet]
  
  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  initial_lifecycle_hook {
    name                 = "green-lifecycle"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

  }
  
  tag {
    key                 = "name"
    value               = "green"
    propagate_at_launch = true
  }

  timeouts {
    delete = "5m"
  }

}

resource "aws_autoscaling_attachment" "green" {
  autoscaling_group_name = aws_autoscaling_group.green.id
  lb_target_group_arn = aws_lb_target_group.green.arn

}


###===============Target Group for ALB ==============###
resource "aws_lb_target_group" "green" {
  name     = "tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 3
    interval = 5
  }
}


