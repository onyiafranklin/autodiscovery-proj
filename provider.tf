provider "aws" {
  region  = "eu-west-2"
  # profile = "bukky_int"

}
provider "vault" {
  address = "https://vault.edenboutique.space"
  token   = "s.2do1ImckleJFcEpNSbSRJTqt"

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