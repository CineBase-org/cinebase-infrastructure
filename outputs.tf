# ========= Frontend Outputs =========

output "cloudfront_domain_name" {
  value = module.frontend.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  value = module.frontend.cloudfront_distribution_id
}

output "s3_bucket_name" {
  value = module.frontend.s3_bucket_name
}

output "s3_bucket_arn" {
  value = module.frontend.s3_bucket_arn
}

output "github_actions_role_arn" {
  value = module.frontend.github_actions_role_arn
}

# ========= Network Outputs =========

output "vpc_id" {
  description = "ID of the vpc"
  value       = module.network.vpc_id
}

output "public_subnets_ids" {
  value = module.network.public_subnets_ids
}

# === Load Balancer Outputs ===

#  output "alb-gs_id" {
#    value = module.loadbalancer.alb-sg.id
#  }

#  output "alb-gs_arn" {
#    value = module.loadbalancer.alb-sg.arn
#  }


