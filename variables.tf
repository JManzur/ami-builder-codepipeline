variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "code_connection" {
  type        = string
  description = "The CodeStart Connection ARN" # Ref.: https://docs.aws.amazon.com/codestar-connections/latest/APIReference/API_Connection.html
}

variable "repository_id" {
  type        = string
  description = "The ID of your git repo in the USER_NAME/REPO_NAME format" # Example: JManzur/ami-builder-codepipeline-packer-repo
}

variable "repository_branch" {
  type        = string
  description = "The branch where the code should be pulled from." # Example: Main
}

variable "compute_type" {
  description = "The compute size that CodeBuild will use to execute the build" # Ref: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition = (
      var.compute_type == "BUILD_GENERAL1_SMALL" ||
      var.compute_type == "BUILD_GENERAL1_MEDIUM" ||
      var.compute_type == "BUILD_GENERAL1_LARGE" ||
      var.compute_type == "BUILD_GENERAL1_2XLARGE"
    )
    error_message = "The value must be one of the followings: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE, BUILD_GENERAL1_2XLARGE"
  }
}

/* Tags Variables */
#Use: tags = merge(var.project-tags, { Name = "${var.resource-name-tag}-place-holder" }, )
variable "project-tags" {
  type = map(string)
  default = {
    Service   = "AMI-Builder-CodePipeline",
    CreatedBy = "JManzur"
    Env       = "POC"
  }
}

#Use: tags = { Name = "${var.name_prefix}-lambda" }
variable "name_prefix" {
  type = string
}

variable "service_role_name" {
  type = map(string)
  default = {
    CodePipeline = "Packer-CodePipeline-Role",
    CodeBuild    = "Packer-CodeBuild-Role"
  }
}