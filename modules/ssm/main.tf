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
  value_wo_version = 1
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