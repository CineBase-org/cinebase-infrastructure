terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}


resource "aws_ecr_repository" "image_repository" {
  name                 = "${var.project-name}-ecr"
  force_delete         = true
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# ======= GitHub Actions role ========
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"
      identifiers = [
        var.github_oidc_provider_arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_organization}/${var.github_repo_back}:ref:refs/heads/main"
      ]
    }
  }
}


resource "aws_iam_role" "github_actions_role" {
  name               = "${var.project-name}-backend-deploy-to-ecr"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}


resource "aws_iam_role_policy" "github_actions_policy" {
  name   = "${var.project-name}-backend-deploy-to-ecr-policy"
  role   = aws_iam_role.github_actions_role.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}


data "aws_iam_policy_document" "github_actions_policy" {

  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage"
    ]

    resources = [
      aws_ecr_repository.image_repository.arn
    ]
  }

}