terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}


resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.project-name}-${var.front_bucket_name}"
  force_destroy = true

  tags = {
    Name = "frontend"
  }
}


resource "aws_s3_bucket_public_access_block" "frontend-block" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ======= cloudfront  =======

resource "aws_cloudfront_origin_access_control" "frontend_oac" {
  name                              = "${var.project-name}-frontend-oac"
  description                       = "Access control for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


data "aws_cloudfront_cache_policy" "frontend_cache_policy" {
  name = "Managed-CachingOptimized"
}


resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_oac.id
    origin_id                = var.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    cache_policy_id = data.aws_cloudfront_cache_policy.frontend_cache_policy.id

    viewer_protocol_policy = "redirect-to-https"

    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["RU", "BY"]
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# ====== s3 bucket policy =====

data "aws_iam_policy_document" "frontend_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values = [
        aws_cloudfront_distribution.frontend.arn
      ]
    }
  }
}


resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id

  policy = data.aws_iam_policy_document.frontend_policy.json
}

# ======= GitHub Actions role ========

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

}


data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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
        "repo:${var.github_organization}/${var.github_repo}:environment:${var.github_environment}"
      ]
    }
  }
}


resource "aws_iam_role" "github_actions_role" {
  name               = "${var.project-name}-frontend-deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
}


resource "aws_iam_role_policy" "github_actions_policy" {
  name   = "${var.project-name}-frontend-deploy-policy"
  role   = aws_iam_role.github_actions_role.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}


data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.frontend.arn}"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "cloudfront:CreateInvalidation"
    ]

    resources = [
      "${aws_cloudfront_distribution.frontend.arn}"
    ]
  }
}