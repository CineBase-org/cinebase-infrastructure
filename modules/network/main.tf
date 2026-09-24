terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

# started to create nework infrastructure. Status in progress

resource "aws_vpc" "vpc" {
	cidr_block = "10.0.0.0/16"
  tags = {
    Name = "mate-aws-team project"
  }
}