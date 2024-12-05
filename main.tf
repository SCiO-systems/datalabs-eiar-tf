module "vpc" {
  source          = "./vpc"
  max_subnet      = 2
  public_sn_count = 2
  public_cidrs    = var.public_cidrs
  private_cidrs   = var.private_cidrs
  name            = var.name
  customer        = var.customer
  vpc_id          = var.vpc_id
  private_rtb_id  = var.private_rtb_id
  public_rtb_id   = var.public_rtb_id
}

module "eks" {
  source          = "./eks"
  region          = var.region
  name            = var.name
  customer        = var.customer
  vpc_id          = var.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  node_groups     = var.node_groups
}

module "efs" {
  source                    = "./efs"
  name                      = var.name
  customer                  = var.customer
  subnets                   = module.vpc.public_subnets
  cluster_security_group_id = [module.eks.cluster_security_group_id]
}
