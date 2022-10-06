/*
category: Possible values are Approval, Build, Deploy, Invoke, Source and Test.
provider: Ref.: https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference.html
*/
resource "aws_codepipeline" "codepipeline" {
  name     = "Windows-AMI-Builder"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_code"]

      configuration = {
        ConnectionArn        = var.code_connection
        FullRepositoryId     = var.repository_id
        BranchName           = var.repository_branch
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }



  stage {
    name = "Validate"

    action {
      name            = "Validate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.validate.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ServiceName"
            value = "windows"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "PackerBuild"

    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1

      configuration = {
        #NotificationArn    = "..."
        CustomData = "By approving this step, you will Build a new AMI."
        #ExternalEntityLink = "..."
      }
    }

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"
      run_order       = 2

      configuration = {
        ProjectName = aws_codebuild_project.build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ServiceName"
            value = "windows"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}

/*
Linux AMI
*/
resource "aws_codepipeline" "codepipeline_linux" {
  name     = "Linux-AMI-Builder"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_code"]

      configuration = {
        ConnectionArn        = var.code_connection
        FullRepositoryId     = var.repository_id
        BranchName           = var.repository_branch
        DetectChanges        = false
        OutputArtifactFormat = "CODEBUILD_CLONE_REF"
      }
    }
  }



  stage {
    name = "Validate"

    action {
      name            = "Validate"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.validate.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ServiceName"
            value = "linux"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "PackerBuild"

    action {
      name      = "Approval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 1

      configuration = {
        #NotificationArn    = "..."
        CustomData = "By approving this step, you will Build a new AMI."
        #ExternalEntityLink = "..."
      }
    }

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_code"]
      version         = "1"
      run_order       = 2

      configuration = {
        ProjectName = aws_codebuild_project.build.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ServiceName"
            value = "linux"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}