variable "project-name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "ssm_parameter" {
  type = string
}
variable "ecs_instance_type" {
  type = string
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