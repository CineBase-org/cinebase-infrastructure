output "image_repository_url" {
  value = aws_ecr_repository.image_repository.repository_url
}

output "image_repository_arn" {
  description = "ECR repository ARN for IAM permissions"
  value       = aws_ecr_repository.image_repository.arn
}

output "image_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.image_repository.name
}