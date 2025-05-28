provider "aws" {
  region  = "eu-west-2"
  # profile = "bukky_int"

}
provider "vault" {
  address = "https://vault.edenboutique.space"
  token   = "s.HEv8RqXswst6nXZdszl0DQoX"

}

terraform {
  backend "s3" {
    bucket         = "bucket-pet-adoption"
    key            = "infrastructure/terraform.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}