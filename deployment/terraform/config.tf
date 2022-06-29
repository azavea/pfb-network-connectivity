provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    encrypt = "true"
  }
}

provider "template" {
  version = "~> 2.1.0"
}

