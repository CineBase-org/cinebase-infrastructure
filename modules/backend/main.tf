terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

resource "aws_security_group" "ecs-ec2-sg" {
  name        = "${var.project-name}-ecs-ec2-sg"
  description = "SG for the ECS EC2 instances"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.project-name}-ecs-ec2-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs-ec2-sg-ingress" {
  security_group_id = aws_security_group.ecs-ec2-sg.id

  referenced_security_group_id = var.alb_sg_id

  ip_protocol = "tcp"
  from_port   = 32768 # dynamic-port-range-start
  to_port     = 65535 # dynamic-port-range-end
  # will allow traffic from the ALB to the ECS EC2 instances on ephemeral ports
}
output "alb-sg_id" {
  value = aws_security_group.alb-sg.id
}

output "alb-sg_arn" {
  value = aws_security_group.alb-sg.arn
}

resource "aws_vpc_security_group_egress_rule" "ecs-ec2-sg-egress" {
  security_group_id = aws_security_group.ecs-ec2-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


resource "aws_iam_role" "ecs_ec2_instance_role" {
  name = "${var.project-name}-ecs-ec2-instance-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_ec2_assume_role_policy.json
}


data "aws_iam_policy_document" "ecs_ec2_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role_policy_attachment" "ecs_ec2_instance_role_policy_attachment" {
  role       = aws_iam_role.ecs_ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "ecs_ec2_instance_profile" {
  name = "${var.project-name}-ecs-ec2-instance-profile"
  role = aws_iam_role.ecs_ec2_instance_role.name
}


data "aws_ssm_parameter" "ecs_ami" {
  name = var.ssm_parameter
}


resource "aws_launch_template" "ecs_ec2_launch_template" {
  name          = "${var.project-name}-ecs-ec2-launch-template"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.ecs_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_ec2_instance_profile.name
  }

  network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs-ec2-sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "ECS_CLUSTER=${aws_ecs_cluster.backend_cluster.name}" >> /etc/ecs/ecs.config
              EOF
  )
}


resource "aws_autoscaling_group" "auto_scaling_group" {
  name                      = "${var.project-name}-ecs-ec2-auto-scaling-group"
  force_delete              = true
  max_size                  = 2
  min_size                  = 0
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 0
  protect_from_scale_in     = true

  launch_template {
    id      = aws_launch_template.ecs_ec2_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.public_subnets_ids

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project-name}-ecs-ec2"
    propagate_at_launch = true
  }

}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.project-name}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.auto_scaling_group.arn
    managed_termination_protection = "ENABLED"
    managed_draining               = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.backend_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

  default_capacity_provider_strategy {
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}


resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "${var.project-name}-ecs-logs"
  retention_in_days = 7

}

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


data "aws_iam_policy_document" "ecs_ssm_policy" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameters"
    ]

    resources = [
      var.db_password_arn,
      var.django_secret_key_arn
    ]
  }
}


resource "aws_iam_role_policy" "ecs_ssm_policy" {
  name = "${var.project-name}-ecs-ssm-policy"

  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_ssm_policy.json
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project-name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.project-name}-task-definition"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name              = "${var.project-name}-container"
      image             = "${var.image_repository_url}:${var.backend_image_tag}"
      cpu               = 256
      memoryReservation = 384
      memory            = 768
      essential         = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 0
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cloudwatch_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "${var.project-name}-ecs"
        }
      }

      environment = [
        {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "cinema_base.settings.prod"
        },
        {
          name  = "POSTGRES_HOST"
          value = var.db_address
        },
        {
          name  = "POSTGRES_DB"
          value = var.db_name
        },
        {
          name  = "POSTGRES_USER"
          value = var.db_username
        },
        {
          name = "POSTGRES_DB_PORT"
          value = tostring(var.db_port)
        },
        {
          name = "POSTGRES_SSLMODE"
          value = "require"
        },
        {
          name = "ALLOWED_HOSTS"
          value = var.allowed_hosts
        },
        {
          name = "CORS_ALLOWED_ORIGINS"
          value = "https://${var.cloudfront_domain_name}"
        }
      ]

      secrets = [
        {
          name = "POSTGRES_PASSWORD"
          valueFrom = var.db_password_arn
        },
        {
          name = "SECRET_KEY"
          valueFrom = var.django_secret_key_arn
        }
      ]
    }
  ])
}


data "aws_iam_policy_document" "ecs_infrastructure_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

  }
}


resource "aws_iam_role" "ecs_infrastructure_role" {
  name = "${var.project-name}-ecs_infrastructure_role"

  assume_role_policy = data.aws_iam_policy_document.ecs_infrastructure_assume_role.json
}


resource "aws_iam_role_policy_attachment" "ecs_infrastructure_attachment" {
  role = aws_iam_role.ecs_infrastructure_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForLoadBalancers"
}

# TODO aws_ecs_service