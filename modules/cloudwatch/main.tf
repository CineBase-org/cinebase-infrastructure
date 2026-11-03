# First backend

resource "aws_cloudwatch_dashboard" "backend" {
  dashboard_name = "${var.project-name}-backend"

  dashboard_body = templatefile("${path.module}/backend.json.tftpl", {
    aws_region                    = var.aws_region
    backend_cluster_name          = var.backend_cluster_name
    backend_service_name          = var.backend_service_name
    backend_asg_name              = var.backend_asg_name
    alb_arn_suffix                = var.alb_arn_suffix
    blue_target_group_arn_suffix  = var.blue_target_group_arn_suffix
    green_target_group_arn_suffix = var.green_target_group_arn_suffix
  })
}

# Second RDS

resource "aws_cloudwatch_dashboard" "database" {
  dashboard_name = "${var.project-name}-database"

  dashboard_body = templatefile("${path.module}/database.json.tftpl", {
    aws_region                    = var.aws_region
    db_instance_identifier        = var.db_instance_identifier
    db_instance_allocated_storage = var.db_instance_allocated_storage
  })
}

# Third frontend

resource "aws_cloudwatch_dashboard" "frontend" {
  dashboard_name = "${var.project-name}-frontend"

  dashboard_body = templatefile("${path.module}/frontend.json.tftpl", {
    cloudfront_distribution_id = var.cloudfront_distribution_id
  })
}

# Alarms

resource "aws_sns_topic" "alerts" {
  name = "${var.project-name}-alerts"
}

resource "aws_sns_topic_subscription" "send_emails" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}


# DB

resource "aws_cloudwatch_metric_alarm" "high_db_cpu" {
  alarm_name        = "rds-high-cpu"
  metric_name       = "CPUUtilization"
  namespace         = "AWS/RDS"
  alarm_description = "CPU utilization on RDS > 80%"

  evaluation_periods = 2
  period             = 60
  statistic          = "Average"

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_disk_free_space" {
  alarm_name          = "low-disk-free-space"
  alarm_description   = "RDS free storage space below 3 GiB"
  comparison_operator = "LessThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  evaluation_periods  = 2
  threshold           = 3 # Gib

  metric_query {
    id = "free_space"
    metric {
      metric_name = "FreeStorageSpace"
      namespace   = "AWS/RDS"
      period      = 300
      stat        = "Minimum"
      dimensions = {

        DBInstanceIdentifier = var.db_instance_identifier
      }
    }
    return_data = false
  }
  metric_query {
    id          = "free_space_gb"
    expression  = "free_space / (1024 * 1024 * 1024)"
    return_data = true
  }
}


# ECS

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name        = "ecs-high-cpu"
  metric_name       = "CPUUtilization"
  namespace         = "AWS/ECS"
  alarm_description = "CPU utilization on ECS service > 80%"

  evaluation_periods = 2
  period             = 60
  statistic          = "Average"

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.backend_cluster_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}


resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name        = "ecs-high-memory"
  metric_name       = "MemoryUtilization"
  namespace         = "AWS/ECS"
  alarm_description = "Memory utilization on ECS service > 80%"

  evaluation_periods = 2
  period             = 60
  statistic          = "Average"

  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.backend_cluster_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ecs-insufficient-tasks" {
  alarm_name        = "ECS live task count below 2"
  metric_name       = "LiveTaskCount"
  namespace         = "AWS/ECS"
  alarm_description = "Live task count below 2"

  evaluation_periods = 2
  period             = 60
  statistic          = "Average"

  threshold           = 2
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  dimensions = {
    ServiceName = var.backend_service_name
    ClusterName = var.backend_cluster_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# Frontend

resource "aws_sns_topic" "frontend_alerts" {
  name   = "${var.project-name}-frontend-alerts"
  region = "us-east-1"
}

resource "aws_sns_topic_subscription" "frontend_emails" {
  region    = "us-east-1"
  topic_arn = aws_sns_topic.frontend_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "frontend_5xx_rate" {
  alarm_name        = "${var.project-name}-cloudfront-5xx-rate"
  alarm_description = "CloudFront 5xx error rate > 5%"

  region = "us-east-1"

  namespace   = "AWS/CloudFront"
  metric_name = "5xxErrorRate"

  dimensions = {
    DistributionId = var.cloudfront_distribution_id
    Region         = "Global"
  }

  statistic = "Average"
  period    = 300

  threshold           = 5
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods  = 3
  datapoints_to_alarm = 2

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.frontend_alerts.arn]
}

# Backend

resource "aws_cloudwatch_metric_alarm" "high_5xx_rate" {
  alarm_name          = "backend-5xx-rate"
  alarm_description   = "Backend 5xx error rate > 5%"
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  evaluation_periods  = 3
  threshold           = 5
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "requests"
    return_data = false
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
    return_data = false
  }

  metric_query {
    id          = "error_rate"
    expression  = "IF(requests >= 20, 100 * errors / requests, 0)"
    return_data = true
  }
}


resource "aws_cloudwatch_metric_alarm" "high_alb_5xx_rate" {
  alarm_name          = "alb-5xx-rate"
  alarm_description   = "ALB 5xx error rate > 5%"
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  evaluation_periods  = 3
  threshold           = 5
  datapoints_to_alarm = 2
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "requests"
    return_data = false
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
  }

  metric_query {
    id = "errors"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 300
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.alb_arn_suffix
      }
    }
    return_data = false
  }

  metric_query {
    id          = "error_rate"
    expression  = "IF((requests + errors) >= 20, 100 * errors / (requests + errors), 0)"
    return_data = true
  }
}