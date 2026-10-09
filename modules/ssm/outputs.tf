output "db_password_arn" {
  value = aws_ssm_parameter.db_password.arn
}

output "django_secret_key_arn" {
  value = aws_ssm_parameter.django_secret_key.arn
}

output "tmdb_api_key_arn" {
  value = aws_ssm_parameter.tmdb_api_key.arn
}