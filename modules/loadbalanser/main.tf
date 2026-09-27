terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}


resource "aws_security_group" "alb-sg" {
  name        = "${var.project-name}-alb-sg"
  description = "SG for the ALB"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.project-name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb-sg-ingress" {
  security_group_id = aws_security_group.alb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb-sg-egress" {
  security_group_id = aws_security_group.alb-sg.id

  cidr_ipv4   = "0.0.0.0/0" # for now but in the future I can put here IP's mine EC2 SG
  ip_protocol = "-1"
}

resource "aws_lb" "lb-backend" {
  name                             = "${var.project-name}-alb"
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb-sg.id]
  subnets                          = var.public_subnets_ids
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "${var.project-name}-alb"
  }
}


resource "aws_lb_listener" "lb-backend" {
  load_balancer_arn = aws_lb.ld-backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

#TODO listener and listener rules