/*
Role: Packer CodeBuild
Description: Used by the CodeBuild Project
*/

data "aws_iam_policy_document" "build_policy_source" {
  statement {
    sid    = "CloudwatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodestarPolicy"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["${var.code_connection}"]
  }

  statement {
    sid    = "ArtifactBucketPolicy"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.artifact.arn}",
      "${aws_s3_bucket.artifact.arn}/*",
    ]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ArtifactBucketKeyPolicy"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["${aws_kms_key.artifact.arn}"]
  }

  statement {
    sid    = "SSMPolicy"
    effect = "Allow"
    actions = [
      "ssm:StartSession",
      "ssm:SendCommand",
      "ssm:GetConnectionStatus",
      "ssm:DescribeInstanceInformation",
      "ssm:TerminateSession",
      "ssm:ResumeSession"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PackerIAMCreateRole"
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:DeleteRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:PutRolePolicy",
      "iam:AddRoleToInstanceProfile"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PackerKeyPolicy"
    effect = "Allow"
    actions = [
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PackerEC2FullAccess"
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codebuild_assume_role_policy" {
  statement {
    sid    = "CodeBuildAssumeRole"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = lower("${var.name_prefix}-codebuild-policy")
  path        = "/"
  description = "CodePipeline Policy"
  policy      = data.aws_iam_policy_document.build_policy_source.json
  tags        = { Name = "${var.name_prefix}-codebuild-policy" }
}

resource "aws_iam_role" "codebuild_role" {
  name               = var.service_role_name["CodeBuild"]
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  tags               = { Name = "${var.service_role_name["CodeBuild"]}" }
}

resource "aws_iam_role_policy_attachment" "build_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

/*
Role: Packer CodePipeline
Description: Used by the CodePipeline Project
*/

data "aws_iam_policy_document" "codepipeline_policy_source" {
  statement {
    sid    = "AllowPassingIAMRoles"
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudwatchPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodeCommitPolicy"
    effect = "Allow"
    actions = [
      "codecommit:GitPull"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CodestarPolicy"
    effect = "Allow"
    actions = [
      "codestar-connections:UseConnection"
    ]
    resources = ["${var.code_connection}"]
  }

  statement {
    sid    = "CodeBuildPolicy"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild",
      "codebuild:StopBuild",
      "codebuild:BatchGetBuilds"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ArtifactPolicy"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.artifact.arn}",
      "${aws_s3_bucket.artifact.arn}/*",
    ]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "KMSKeyPolicy"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["${aws_kms_key.artifact.arn}"]
  }

  statement {
    sid    = "PackerEC2FullAccess"
    effect = "Allow"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    sid    = "CodeStartAssumeRole"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = lower("${var.name_prefix}-codepipeline-policy")
  path        = "/"
  description = "CodePipeline Policy"
  policy      = data.aws_iam_policy_document.codepipeline_policy_source.json
  tags        = { Name = "${var.name_prefix}-codepipeline-policy" }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = var.service_role_name["CodePipeline"]
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  tags               = { Name = "${var.service_role_name["CodePipeline"]}" }
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}