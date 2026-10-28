variable "project-name" {
  description = "The name of the project"
  type        = string
}

variable "github_oidc_provider_arn" {
  type = string
}

variable "github_organization" {
  type = string
}

variable "github_repo_back" {
  type = string
}
