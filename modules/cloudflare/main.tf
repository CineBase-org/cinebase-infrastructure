terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.27.0"
    }
  }
}

resource "cloudflare_dns_record" "cloudflare_dns_records" {

  for_each = var.acm_validation_records
  type     = each.value.type
  name     = trimsuffix(each.value.name, ".")
  content  = trimsuffix(each.value.content, ".")

  zone_id = var.cloudflare_zone_id
  ttl     = "1"
  proxied = false

}

resource "cloudflare_dns_record" "frontend" {
  name    = var.domain_name
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  content = var.cloudfront_domain_name
  proxied = false
  ttl     = 1
}


resource "cloudflare_dns_record" "backend" {
  name    = "api.${var.domain_name}"
  zone_id = var.cloudflare_zone_id
  type    = "CNAME"
  content = var.alb_dns_name
  proxied = false
  ttl     = 1
}