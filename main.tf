module "network" {
  source = "./modules/network"

  project-name   = var.project-name
  vpc_cidr_block = var.vpc_cidr_block
  subnets        = var.subnets

}


module "loadbalancer" {
  source = "./modules/loadbalancer"

  project-name            = var.project-name
  vpc_id                  = module.network.vpc_id
  public_subnets_ids      = module.network.public_subnets_ids
  backend_certificate_arn = aws_acm_certificate_validation.certificates["backend"].certificate_arn

}

module "cloudflare" {
  source = "./modules/cloudflare"

  cloudflare_zone_id     = var.cloudflare_zone_id
  cloudfront_domain_name = module.frontend.cloudfront_domain_name
  domain_name            = var.domain_name
  alb_dns_name           = module.loadbalancer.alb_dns_name

  acm_validation_records = {
    frontend = {
      name    = one(module.acm_frontend.domain_validation_options).resource_record_name
      type    = one(module.acm_frontend.domain_validation_options).resource_record_type
      content = one(module.acm_frontend.domain_validation_options).resource_record_value
    }

    backend = {
      name    = one(module.acm_backend.domain_validation_options).resource_record_name
      type    = one(module.acm_backend.domain_validation_options).resource_record_type
      content = one(module.acm_backend.domain_validation_options).resource_record_value
    }
  }
}

module "github-oidc" {
  source = "./modules/github-oidc"
}


module "ecr" {
  source                   = "./modules/ecr"
  project-name             = var.project-name
  github_oidc_provider_arn = module.github-oidc.github_oidc_provider_arn
  github_organization      = var.github_organization
  github_repo_back         = var.github_repo_back
}


module "frontend" {
  source = "./modules/frontend"

  project-name             = var.project-name
  front_bucket_name        = var.front_bucket_name
  s3_origin_id             = var.s3_origin_id
  github_repo              = var.github_repo
  github_organization      = var.github_organization
  github_environment       = var.github_environment
  github_oidc_provider_arn = module.github-oidc.github_oidc_provider_arn
  acm_certificate_arn      = aws_acm_certificate_validation.certificates["frontend"].certificate_arn
  domain_name              = var.domain_name
}


module "ssm" {
  source = "./modules/ssm"

  project-name      = var.project-name
  db_password       = var.db_password
  django_secret_key = var.django_secret_key
  tmdb_api_key      = var.tmdb_api_key

}

module "database" {
  source = "./modules/database"

  project-name        = var.project-name
  private_subnets_ids = module.network.private_subnets_ids
  vpc_id              = module.network.vpc_id
  ecs_ec2_sg_id       = module.backend.ecs_ec2_sg_id
  db_password         = var.db_password
}

module "backend" {
  source = "./modules/backend"

  project-name                 = var.project-name
  vpc_id                       = module.network.vpc_id
  alb_sg_id                    = module.loadbalancer.alb_sg_id
  ssm_parameter                = var.ssm_parameter
  ecs_instance_type            = var.ecs_instance_type
  public_subnets_ids           = module.network.public_subnets_ids
  aws_region                   = var.aws_region
  backend_image_tag            = var.backend_image_tag
  image_repository_url         = module.ecr.image_repository_url
  db_address                   = module.database.db_address
  db_name                      = module.database.db_name
  db_username                  = module.database.db_username
  db_port                      = module.database.db_port
  db_password_arn              = module.ssm.db_password_arn
  django_secret_key_arn        = module.ssm.django_secret_key_arn
  tmdb_api_key_arn             = module.ssm.tmdb_api_key_arn
  cloudfront_domain_name       = module.frontend.cloudfront_domain_name
  allowed_hosts                = "api.${var.domain_name}"
  blue_target_group_arn        = module.loadbalancer.blue_target_group_arn
  green_target_group_arn       = module.loadbalancer.green_target_group_arn
  production_listener_rule_arn = module.loadbalancer.production_listener_rule_arn
  domain_name                  = var.domain_name
}


module "acm_frontend" {
  source      = "./modules/acm"
  domain_name = var.domain_name

  providers = {
    aws = aws.us_east_1
  }
}

module "acm_backend" {
  source      = "./modules/acm"
  domain_name = "api.${var.domain_name}"
}


resource "aws_acm_certificate_validation" "certificates" {
  for_each = {
    frontend = {
      certificate_arn = module.acm_frontend.certificate_arn
      record_fqdn     = module.cloudflare.validation_record_fqdns["frontend"]
      region          = "us-east-1"
    }

    backend = {
      certificate_arn = module.acm_backend.certificate_arn
      record_fqdn     = module.cloudflare.validation_record_fqdns["backend"]
      region          = "eu-central-1"
    }
  }

  region          = each.value.region
  certificate_arn = each.value.certificate_arn
  validation_record_fqdns = [
    format("%s.", trimsuffix(each.value.record_fqdn, "."))
  ]
}

# the code above is the same that the commented under one
# resource "aws_acm_certificate_validation" "frontend" {


#   certificate_arn         = module.acm_frontend.certificate_arn
#   validation_record_fqdns = module.cloudflare.validation_record_fqdns["frontend"]

#   provider = aws.us_east_1

# }

# resource "aws_acm_certificate_validation" "backend" {


#   certificate_arn         = module.acm_backend.certificate_arn
#   validation_record_fqdns = module.cloudflare.validation_record_fqdns["backend"]

# }

