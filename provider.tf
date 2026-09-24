terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
  backend "s3" {
    bucket       = "team-project-remote-state-976134557491-eu-central-1-an"
    key          = "cinebase/state/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
