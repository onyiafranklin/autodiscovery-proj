locals {
  name = "auto-discov"
}
module "vpc" {
  source = "./module/vpc"
  name   = local.name
  az1    = "eu-west-2a"
  az2    = "eu-west-2b"
}
module "bastion" {
    source     = "./module/bastion"
    name       = local.name
    vpc        = module.vpc.vpc_id
    keypair    = module.vpc.public_key
    subnets    = [module.vpc.pub_sub1_id, module.vpc.pub_sub2_id]
    privatekey = module.vpc.private_key

  
}