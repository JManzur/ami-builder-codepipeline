data "aws_caller_identity" "current" {}

module "vpc" {
  count       = var.DeployVPC ? 1 : 0
  source      = "./modules/vpc"
  name_prefix = var.name_prefix
  aws_region  = var.aws_region
}

module "codepipeline" {
  source                  = "./modules/codepipeline"
  codepipeline_account_id = data.aws_caller_identity.current.account_id
  name_prefix             = var.name_prefix
  service_role_name       = var.service_role_name
  code_connection         = var.code_connection
  repository_id           = var.repository_id
  repository_branch       = var.repository_branch
  compute_type            = var.compute_type
  aws_profile             = var.aws_profile
  vpc_id                  = var.DeployVPC ? module.vpc[0].vpc_id : var.preexisting_vpc_id
  private_subnet          = var.DeployVPC ? module.vpc[0].private_subnet[0] : var.preexisting_private_subnet
}