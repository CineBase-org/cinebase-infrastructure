variable "project-name" {
  type        = string
  description = "The name of the project"
}

variable "private_subnets_ids" {
  type        = list(string)
  description = "List of private subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "ecs_ec2_sg_id" {
  type        = string
  description = "The ID of the ECS EC2 security group"
}

variable "db_password" {
  type        = string
  description = "The password for the RDS database"
  sensitive   = true
  ephemeral   = true
}