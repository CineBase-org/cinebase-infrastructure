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

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_service_arn" {
  type = string
}

variable "ecs_task_definition_arn_without_revision" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

variable "backend_task_role_arn" {
  type = string
}