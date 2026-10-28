variable "project-name" {
  type        = string
  description = "The name of the project"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets_ids" {
  type = list(string)
}

variable "backend_certificate_arn" {
  type = string
}