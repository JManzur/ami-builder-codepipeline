/*
Role: packer CodeBuild
Description: Used by the CodeBuild Project
*/

data "aws_iam_policy_document" "buil_policy_source" {
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
    sid    = "PackerEC2Policy"
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CopyImage",
      "ec2:CreateImage",
      "ec2:CreateKeypair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSnapshot",
      "ec2:DeleteVolume",
      "ec2:DeregisterImage",
      "ec2:DescribeImageAttribute",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSnapshots",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DetachVolume",
      "ec2:GetPasswordData",
      "ec2:ModifyImageAttribute",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifySnapshotAttribute",
      "ec2:RegisterImage",
      "ec2:RunInstances",
      "ec2:StopInstances",
      "ec2:TerminateInstances",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:CreateFleet",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeVpcs"
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
  policy      = data.aws_iam_policy_document.buil_policy_source.json
  tags        = { Name = "${var.name_prefix}-codebuild-policy" }
}

resource "aws_iam_role" "codebuild_role" {
  name               = var.codebuild_role
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role_policy.json
  tags               = { Name = "${var.codebuild_role}" }
}

resource "aws_iam_role_policy_attachment" "build_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

/*
Role: packer CodePipeline
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
  name               = var.codepipeline_role
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
  tags               = { Name = "${var.codepipeline_role}" }
}

resource "aws_iam_role_policy_attachment" "codepipeline_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}