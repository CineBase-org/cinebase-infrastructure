output "certificate_arn" {
  value = aws_acm_certificate.acm_certificate.arn
}

output "domain_validation_options" {
  value = aws_acm_certificate.acm_certificate.domain_validation_options
}