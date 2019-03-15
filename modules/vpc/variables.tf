variable "vpc_name" {
  default = "main"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = ["10.0.0.0/24"]
}

variable "public_subnets" {
  default = ["10.0.1.0/24"]
}

variable "azs" {
  type = "list"
}

variable "tags" {
  description = "Tags used for the AWS resources created by this template"
  type        = "map"
}
