terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

resource "aws_iam_user" "analyst" {
  name = "cinebase-analyst"

  tags = {
    Project = "cinebase"
    Role    = "data-analyst"
  }
}

resource "aws_iam_user_policy" "analyst_policy" {
  name   = "${var.project-name}-analyst-policy"
  user   = aws_iam_user.analyst.name
  policy = data.aws_iam_policy_document.analyst_policy.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "analyst_policy" {
  statement {
    sid    = "StartSessionOnCinebaseInstances"
    effect = "Allow"

    actions = [
      "ssm:StartSession"
    ]

    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Name"
      values   = ["${var.project-name}-ecs-ec2"]
    }
    condition {
      test     = "BoolIfExists"
      variable = "ssm:SessionDocumentAccessCheck"
      values   = ["true"]
    }
  }
  statement {
    sid    = "AllowPortForwardingDocument"
    effect = "Allow"

    actions = [
      "ssm:StartSession",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}::document/AWS-StartPortForwardingSessionToRemoteHost"
    ]
  }
  statement {
    sid    = "ManageOwnSessions"
    effect = "Allow"

    actions = [
      "ssmmessages:OpenDataChannel",
      "ssm:ResumeSession",
      "ssm:TerminateSession"
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:session/$${aws:username}-*"
    ]
  }
}