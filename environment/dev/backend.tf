provider "aws" {
  region = "eu-west-2"
}

module "backend" {
  source = "../../modules/backend"

  bucket_name = "dog-dev-terraform-state"
  table_name = "dev-terraform-lock"
}
