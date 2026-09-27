output "vpc_id" {
  description = "ID of the vpc"
  value       = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value = [
    for key, subnet in aws_subnet.subnets :
    subnet.id
    if var.subnets[key].public
  ]
}