terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "mustafa-tf-state2025"
    key    = "env/state/terraform.tfstate"
    region = "eu-north-1" # Replace with your desired region
    #dynamodb_table = "terraform-locks"

  }
}
provider "aws" {
  region     = "eu-north-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
