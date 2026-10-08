variable "project-name" {
  description = "The name of the project"
  type        = string
}

# ================== NETWORK ===================

variable "vpc_cidr_block" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
  }))
}

# ================== FRONTEND ===================

variable "front_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for the frontend"
}

variable "s3_origin_id" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "The GitHub repository URL for the frontend code"
}

variable "github_organization" {
  type        = string
  description = "The GitHub organization for the frontend code"
}

variable "github_environment" {
  type        = string
  description = "The GitHub environment to deploy to"
}

# ================== BACKEND ===================

# variable "ssm_parameter" {
#   type = string
# }

# variable "ecs_instance_type" {
#   type = string
# }

# variable "public_subnets_ids" {
#   type = list(string)
# }

# variable "aws_region" {
#   type = string
# }

# variable "backend_image_tag" {
#   type = string
# }