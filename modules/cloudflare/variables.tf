variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare DNS Zone ID"
}

variable "acm_validation_records" {
  type = map(object({
    name    = string
    type    = string
    content = string
  }))
}

variable "cloudfront_domain_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "domain_name" {
  type = string
}