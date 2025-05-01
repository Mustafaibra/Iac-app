terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "eu-north-1"
  access_key = var.aws_access_key  
  secret_key = var.aws_secret_key
}        
