# output "TERRAFORM_APPLY_ROLE_NAME" {
#   value = var.terrraform_apply_role
# }

output "CODEBUILD_ROLE_ARN" {
  value = module.codepipeline.CODEBUILD_ROLE_ARN
}