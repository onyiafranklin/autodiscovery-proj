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
module "nexus" {
  source              = "./module/nexus"
  subnet-id           = module.vpc.pub_sub1_id
  keypair             = module.vpc.public_key
  name                = local.name
  vpc                 = module.vpc.vpc_id
  baston-sg           = module.bastion.bastion-sg
  subnet1_id          = module.vpc.pub_sub1_id
  subnet2_id          = module.vpc.pri_sub2_id
  acm_certificate_arn = data.aws_acm_certificate.acm-cert.arn
  domain              = var.domain
    nr-key              = var.nr-key
    nr-id               = var.nr-id

 
}
module "prod-env" {
  source       = "./module/prod-env"
  name         = local.name
  vpc-id       = module.vpc.vpc_id
  bastion      = module.bastion.bastion-sg
  key-name     = module.vpc.public_key
  pri-subnet1  = module.vpc.pri_sub1_id
  pri-subnet2  = module.vpc.pri_sub2_id
  pub-subnet1  = module.vpc.pub_sub1_id
  pub-subnet2  = module.vpc.pub_sub2_id
  acm-cert-arn = data.aws_acm_certificate.acm-cert.arn
  domain       = var.domain
  nexus-ip     = module.nexus.nexus_ip
  nr-key       = var.nr-key
  nr-acct-id   = var.nr-id  
  ansible =  ""
}
module "stage-env" {
  source       = "./module/stage-env"
  name         = local.name
  vpc-id       = module.vpc.vpc_id
  bastion      = module.bastion.bastion-sg
  key-name     = module.vpc.public_key
  pri-subnet1  = module.vpc.pri_sub1_id
  pri-subnet2  = module.vpc.pri_sub2_id
  pub-subnet1  = module.vpc.pub_sub1_id
  pub-subnet2  = module.vpc.pub_sub2_id
  acm-cert-arn = data.aws_acm_certificate.acm-cert.arn
  domain       = var.domain
  nexus-ip     = module.nexus.nexus_ip
  nr-key       = var.nr-key
  nr-acct-id   = var.nr-id  
  ansible =  ""
}
 
module "sonarqube" {
  source              = "./module/sonarqube"
  key                 = module.vpc.public_key
  name                = local.name
  subnet_id           = module.vpc.pub_sub1_id
  bastion             = module.bastion.bastion-sg
  vpc-id              = module.vpc.vpc_id
  domain              = var.domain
  public_subnets      = [module.vpc.pub_sub1_id, module.vpc.pub_sub2_id]
  acm_certificate_arn = data.aws_acm_certificate.acm-cert.arn
    nr-key              = var.nr-key
    nr-id               = var.nr-id
}
module "database" {
  source    = "./module/database"
  name      = local.name
  pri-sub-1 = module.vpc.pri_sub1_id
  pri-sub-2 = module.vpc.pri_sub2_id
  bastion   = module.bastion.bastion-sg
  vpc-id    = module.vpc.vpc_id
  stage-sg  = module.stage-env.stage-sg
  prod-sg   = module.prod-env.prod-sg
}
module "ansible" {
  source    = "./module/ansible"
  name      = local.name
  keypair   = module.vpc.public_key
  subnet_id = module.vpc.pri_sub1_id
  vpc       = module.vpc.vpc_id
  bastion   = module.bastion.bastion-sg
  private-key = module.vpc.private_key
  deployment = "./module/ansible/deployment.yml" # Path to the deployment file
  prod-bashscript = "./module/ansible/prod-bashscript.sh" # Path to the prod bash script
  stage-bashscript = "./module/ansible/stage-bashscript.sh" # Path to the stage bash script
  nexus-ip = module.nexus.nexus_ip
  nr-key = var.nr-key
  nr-acc-id = var.nr-id
}


data "aws_acm_certificate" "acm-cert" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

  
