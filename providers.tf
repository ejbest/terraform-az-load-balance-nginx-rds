# provider "vault" {}

# data "vault_aws_access_credentials" "terraform" {
#   backend = "aws"
#   role    = "terraform-test"
# }

provider "aws" {
  region     = "us-east-1"
  # access_key = data.vault_aws_access_credentials.terraform.access_key
  # secret_key = data.vault_aws_access_credentials.terraform.secret_key
}

//Variables 

terraform {
  required_version = ">= 0.13.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }
}
