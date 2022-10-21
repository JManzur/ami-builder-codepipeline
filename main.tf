data "aws_caller_identity" "current" {}

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
}