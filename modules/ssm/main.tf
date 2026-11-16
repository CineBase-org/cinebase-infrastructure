terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}


resource "aws_ssm_parameter" "db_password" {
  name             = "/${var.project-name}/prod/database/password"
  description      = "PostgreSQL password for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.db_password
  value_wo_version = 2
}


resource "aws_ssm_parameter" "django_secret_key" {
  name             = "/${var.project-name}/prod/django/secret_key"
  description      = "Django secret key for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.django_secret_key
  value_wo_version = 1
}


resource "aws_ssm_parameter" "tmdb_api_key" {
  name             = "/${var.project-name}/prod/tmdb/api_key"
  description      = "TMDB API key for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.tmdb_api_key
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_secret_key" {
  name             = "/${var.project-name}/prod/stripe/secret_key"
  description      = "Stripe secret key for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.stripe_secret_key
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_webhook_secret" {
  name             = "/${var.project-name}/prod/stripe/webhook_secret"
  description      = "Stripe webhook secret for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.stripe_webhook_secret
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_price_id" {
  name             = "/${var.project-name}/prod/stripe/price_id"
  description      = "Stripe price ID for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = var.stripe_price_id
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_success_url" {
  name             = "/${var.project-name}/prod/stripe/success_url"
  description      = "Stripe success URL for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = "https://${var.domain_name}/payment/success"
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_cancel_url" {
  name             = "/${var.project-name}/prod/stripe/cancel_url"
  description      = "Stripe cancel URL for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = "https://${var.domain_name}/payment/cancel"
  value_wo_version = 1
}

resource "aws_ssm_parameter" "stripe_portal_return_url" {
  name             = "/${var.project-name}/prod/stripe/portal_return_url"
  description      = "Stripe portal return URL for CineBase"
  type             = "SecureString"
  tier             = "Standard"
  value_wo         = "https://${var.domain_name}/profile"
  value_wo_version = 1
}