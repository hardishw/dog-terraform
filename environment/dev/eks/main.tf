provider "aws" {
  region = "eu-west-2"
}

data "terraform_remote_state" "aws_vpc" {
  backend = "s3"

  config {
    bucket         = "dog-dev-terraform-state"
    key            = "vpc/remote"
    region         = "eu-west-2"
    dynamodb_table = "dev-terraform-lock"
  }
}

terraform {
  backend "s3" {
    bucket         = "dog-dev-terraform-state"
    key            = "eks/remote"
    region         = "eu-west-2"
    dynamodb_table = "dev-terraform-lock"
  }
}

resource "aws_iam_role" "eks_role" {
  name = "EKSServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = "${aws_iam_role.eks_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  role       = "${aws_iam_role.eks_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_eks_cluster" "kubernetes" {
  name     = "dog"
  role_arn = "${aws_iam_role.eks_role.arn}"

  vpc_config {
    subnet_ids = ["${data.terraform_remote_state.aws_vpc.public_subnets}"]
  }
}
