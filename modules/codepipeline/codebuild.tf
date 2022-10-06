/*
Docker images provided by CodeBuild
Ref.: https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-available.html
*/

/* Build Spec files */
data "local_file" "packer_validate" {
  filename = "${path.module}/buildspec/packer_validate.yml"
}

data "local_file" "packer_build" {
  filename = "${path.module}/buildspec/packer_build.yml"
}

/* packer Validate Project */
resource "aws_codebuild_project" "validate" {
  name         = "packer-validate"
  description  = "Execute a packer Validate"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = "aws/codebuild/standard:5.0" #Ubuntu 20.04
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    buildspec = data.local_file.packer_validate.content
    type      = "CODEPIPELINE"
  }

  tags = { Name = "${var.name_prefix}-validation-step" }
}

/* packer Build Project */
resource "aws_codebuild_project" "build" {
  name         = "packer-build"
  description  = "Execute a packer build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.compute_type
    image                       = "aws/codebuild/standard:5.0" #Ubuntu 20.04
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    buildspec = data.local_file.packer_build.content
    type      = "CODEPIPELINE"
  }

  tags = { Name = "${var.name_prefix}-build-step" }
}