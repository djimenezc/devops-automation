terraform {
  required_version = ">= 1.1"
  required_providers {
    aws = {
      source  = "aws"
      version = "3.70"
    }
    external = {
      source  = "external"
      version = "~> 2.1.0"
    }
    random = {
      source  = "random"
      version = "~> 3.1.0"
    }
    tls = {
      source  = "tls"
      version = "~> 3.1.0"
    }
  }
  backend "s3" {
    key                  = "terraform.tfstate"
    workspace_key_prefix = "ec2"
    region               = "eu-west-1"
    dynamodb_table       = "terraform-locks"
    session_name         = "terraform"
    encrypt              = true
  }
}
