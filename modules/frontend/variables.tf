variable "front_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for the frontend"
}

variable "project-name" {
  type = string
}

variable "s3_origin_id" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name with immutable repository ID"
}

variable "github_environment" {
  type        = string
  description = "The GitHub environment to deploy to"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization name with immutable owner ID"
}