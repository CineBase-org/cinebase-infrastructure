output "db_password_arn" {
  value = aws_ssm_parameter.db_password.arn
}

output "django_secret_key_arn" {
  value = aws_ssm_parameter.django_secret_key.arn
}

output "tmdb_api_key_arn" {
  value = aws_ssm_parameter.tmdb_api_key.arn
}

output "stripe_secret_key_arn" {
  value = aws_ssm_parameter.stripe_secret_key.arn
}

output "stripe_webhook_secret_arn" {
  value = aws_ssm_parameter.stripe_webhook_secret.arn
}

output "stripe_price_id_arn" {
  value = aws_ssm_parameter.stripe_price_id.arn
}

output "stripe_cancel_url_arn" {
  value = aws_ssm_parameter.stripe_cancel_url.arn
}

output "stripe_success_url_arn" {
  value = aws_ssm_parameter.stripe_success_url.arn
}

output "stripe_portal_return_url_arn" {
  value = aws_ssm_parameter.stripe_portal_return_url.arn
}