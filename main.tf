module "network" {
  source = "./modules/network"

  project-name   = var.project-name
  vpc_cidr_block = var.vpc_cidr_block
  subnets        = var.subnets

}