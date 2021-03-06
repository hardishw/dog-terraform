provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket         = "dog-dev-terraform-state"
    key            = "vpc/remote"
    region         = "eu-west-2"
    dynamodb_table = "dev-terraform-lock"
  }
}

module "vpc" {
  source = "../../../modules/vpc"

  vpc_name = "dog-mywebsite"
  cidr_block = "172.16.0.0/16"
  private_subnets = ["172.16.0.0/24"]
  public_subnets = ["172.16.10.0/24","172.16.11.0/24"]
  azs = ["eu-west-2a","eu-west-2b"]

  tags = {
    Name = "dog-website"
    Owner     = "devops"
    Environment = "dev"
  }
}
