
###=============Application Load Balancer=============###
#provision security group for application load balancer
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow inbound public traffic and outbound ASG"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Name = "security_grp_app_load_balancer"
  }

  ingress {
    description      = "TLS from outside world"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
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
    forward {
      target_group {
        arn =   aws_lb_target_group.blue.arn
        weight = 70
      }
    
      target_group {
        arn =   aws_lb_target_group.green.arn
        weight = 30
    }
      stickiness {
        enabled  = false
        duration = 1
  }
}
  }
}

resource "aws_wafv2_web_acl" "prod" {
  name  = "WAF-for-production-lb"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }

  rule {
    name = "my-first-rule"
    priority = 1
    override_action {
      count{}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name = "first-rule-metric"
      sampled_requests_enabled = false
    }

    statement {
      managed_rule_group_statement {
        name = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
        rule_action_override {
          action_to_use {
            block{}
          }
          name = "AdminProtection_URIPATH"
        }
}
    }
  }
}

resource "aws_wafv2_web_acl_association" "prod" {
  resource_arn = aws_lb.prod.arn
  web_acl_arn  = aws_wafv2_web_acl.prod.arn
}