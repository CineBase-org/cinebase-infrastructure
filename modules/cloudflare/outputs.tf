output "validation_record_fqdns" {
  value = {
    for key, record in cloudflare_dns_record.cloudflare_dns_records :
    key => record.name
  }
}