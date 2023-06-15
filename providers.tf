provider "vault" {}

data "vault_aws_access_credentials" "terraform" {
  backend = "aws"
  role    = "terraform-test"
}

provider "aws" {
  region     = "us-east-1"
  access_key = data.vault_aws_access_credentials.terraform.access_key
  secret_key = data.vault_aws_access_credentials.terraform.secret_key
}