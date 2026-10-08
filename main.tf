module "network" {
  source = "./modules/network"

  project-name   = var.project-name
  vpc_cidr_block = var.vpc_cidr_block
  subnets        = var.subnets

}


module "github-oidc" {
  source = "./modules/github-oidc"
}


module "ecr" {
  source       = "./modules/ecr"
  project-name = var.project-name
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
}


