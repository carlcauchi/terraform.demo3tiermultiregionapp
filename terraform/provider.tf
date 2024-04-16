terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=5.45.0"
    }
  }
  required_version = ">=1.7.5"
}

# Configure Default AWS Provider Region
provider "aws" {
  region = "eu-central-1"
}

# Configure Alias for additional AWS Provider Region
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}