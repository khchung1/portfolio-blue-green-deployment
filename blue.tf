###=========EC2 Instances===========###

resource "aws_security_group" "blue" {
  name        = "blue-sg"
  description = "Allow alb traffic to app"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]

  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_launch_template" "blue" {
  name_prefix   = "blue-"
  image_id      = data.aws_ami.blue.id
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.blue.id}"]
  #user_data = filebase64("${path.module}/init-script.sh")
  key_name = "kokhui-key"
  
  
  # network_interfaces {
  #   associate_public_ip_address = true
  #   security_groups             = ["${aws_security_group.blue.id}"]
  # }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "blue-Instance-"
    }
  }
}

###=============Auto Scaling Group (ASG)=============###
resource "aws_autoscaling_group" "blue" {
  name = "asg"
  #availability_zones        = ["ap-southeast-1a", "ap-southeast-1b"]
  max_size            = 4
  min_size            = 2
  desired_capacity    = 2
  force_delete        = true
  vpc_zone_identifier = data.aws_subnets.public.ids

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  initial_lifecycle_hook {
    name                 = "blue-lifecycle"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"

    # notification_metadata = jsonencode({
    #   foo = "bar"
    # })

    # notification_target_arn = "arn:aws:sqs:us-east-1:444455556666:queue1*"
    # role_arn                = "arn:aws:iam::123456789012:role/S3Access"
  }

  tag {
    key                 = "name"
    value               = "blue"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "blue" {
  autoscaling_group_name = aws_autoscaling_group.blue.id
  #elb    = aws_lb.prod.id
  lb_target_group_arn = aws_lb_target_group.blue.arn

}


###===============Target Group for ALB ==============###
resource "aws_lb_target_group" "blue" {
  name     = "tg-blue"
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


