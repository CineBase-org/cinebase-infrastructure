terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.8.1"
    }

  }
}

data "aws_iam_policy_document" "lambda_iam_policy_document" {

  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name = "${var.project-name}-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.lambda_iam_policy_document.json

}

resource "aws_iam_role_policy_attachment" "lambda_iam_role_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/smoke_tests"
  output_path = "${path.module}/smoke_tests.zip"
}

resource "aws_lambda_function" "lambda_function_smoke_tests" {
  function_name    = "${var.project-name}-smoke-tests"
  role             = aws_iam_role.lambda_iam_role.arn
  runtime          = "python3.13"
  handler          = "cinebase_smoke_tests.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.cloudwatch_log_group_lambda.name
  }
  environment {
    variables = {
      SMOKE_TEST_BASE_URL = "https://api.${var.domain_name}"
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_iam_role_policy_attachment
  ]
}


data "aws_iam_policy_document" "ecs_hook_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

  }
}

data "aws_iam_policy_document" "ecs_hook_policy" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = [
      aws_lambda_function.lambda_function_smoke_tests.arn
    ]
  }
}

resource "aws_iam_role_policy" "ecs_hook_policy" {
  name = "${var.project-name}-ecs-hook-policy"

  role   = aws_iam_role.lambda_iam_role_hook.id
  policy = data.aws_iam_policy_document.ecs_hook_policy.json
}

resource "aws_iam_role" "lambda_iam_role_hook" {
  name = "${var.project-name}-lambda-hook-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_hook_assume_role.json
}


resource "aws_cloudwatch_log_group" "cloudwatch_log_group_lambda" {
  name              = "${var.project-name}-smoke-tests-logs"
  retention_in_days = 7
}