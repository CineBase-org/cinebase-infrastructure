variable "project-name" {
  type        = string
  description = "The name of the project"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "alb_sg_id" {
  type        = string
  description = "The ID of the Application Load Balancer security group"
}

variable "ssm_parameter" {
  type        = string
  description = "The SSM parameter name"
}
variable "ecs_instance_type" {
  type        = string
  description = "The instance type for ECS tasks"
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "aws_region" {
  type = string
}

variable "backend_image_tag" {
  type = string
}

variable "image_repository_url" {
  type = string
}

variable "db_address" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_port" {
  type = number
}

variable "db_password_arn" {
  type = string
}

variable "django_secret_key_arn" {
  type = string
}

variable "cloudfront_domain_name" {
  type = string
}

variable "allowed_hosts" {
  type = string
}