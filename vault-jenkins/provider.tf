provider "aws" {
  region  = "eu-west-2"
  profile = "bukky_int"
}

terraform {
  backend "s3" {
    bucket       = "bucket-pet-adoption"
    key          = "vault-jenkins/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    profile      = "bukky_int"
    use_lockfile = true
  }
}