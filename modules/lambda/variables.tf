variable "project-name" {
  description = "The name of the project"
  type        = string
}

variable "domain_name" {
  description = "Base domain name for CineBase"
  type        = string
}

variable "smoke_test_listener_rule_arn" {
  type        = string
  description = "lb listener rule arn for smoke test listener"
}