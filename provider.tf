terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.27.0"
    }
  }
  backend "s3" {
    bucket       = "team-project-remote-state-976134557491-eu-central-1-an"
    key          = "cinebase/state/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}

provider "cloudflare" {
  # API Token is getting from the env
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}