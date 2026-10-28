variable "domain_name" {
  type        = string
  description = "my domain name"
}

variable "alternative_domain_names" {
  type        = set(string)
  default     = []
  description = "alternative DN"
}