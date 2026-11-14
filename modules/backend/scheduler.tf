resource "aws_scheduler_schedule" "scheduler_import" {
  name  = "${var.project-name}-scheduler"
  state = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(30 days)"

  target {
    arn      = aws_ecs_cluster.backend_cluster.arn
    role_arn = aws_iam_role.scheduler_role.arn

    ecs_parameters {
      task_definition_arn = "${aws_ecs_task_definition.task_definition.arn_without_revision}:14"
      task_count          = 1

      capacity_provider_strategy {
        capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
        weight            = 1
      }
    }

    input = jsonencode({
      containerOverrides = [
        {
          name    = "${var.project-name}-container",
          command = ["python", "manage.py", "import_movies", "--source", "new"]
        }
      ]
    })
  }
}

data "aws_iam_policy_document" "scheduler_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "scheduler_role" {
  name               = "${var.project-name}-scheduler-role"
  assume_role_policy = data.aws_iam_policy_document.scheduler_assume_role.json
}

data "aws_iam_policy_document" "scheduler_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "ecs:RunTask",
    ]

    resources = [
      "${aws_ecs_task_definition.task_definition.arn_without_revision}:14",
    ]
    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [aws_ecs_cluster.backend_cluster.arn]
    }
  }
  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.ecs_task_execution_role.arn,
      aws_iam_role.backend_task_role.arn
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "scheduler_policy" {
  name   = "${var.project-name}-scheduler-policy"
  role   = aws_iam_role.scheduler_role.id
  policy = data.aws_iam_policy_document.scheduler_permissions.json
}