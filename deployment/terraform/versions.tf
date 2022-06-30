
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1.0"
    }
  }
}
