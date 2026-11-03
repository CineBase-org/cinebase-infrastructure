variable "project-name" {
  description = "The name of the project"
  type        = string
}

variable "aws_region" {
  type = string
}

variable "backend_cluster_name" {
  type = string
}

variable "backend_service_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "blue_target_group_arn_suffix" {
  type = string
}

variable "green_target_group_arn_suffix" {
  type = string
}

variable "backend_asg_name" {
  type = string
}

variable "db_instance_identifier" {
  type = string
}

variable "db_instance_allocated_storage" {
  type = string
}

variable "cloudfront_distribution_id" {
  type = string
}

variable "alert_email" {
  type = string
}