resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.tags["Name"]}-codepipeline-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.tags["Name"]}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Action": [
        "codestar-connections:UseConnection"
      ],
    "Resource": "*",
    "Effect": "Allow"
    },
    {
    "Action": [
        "appconfig:StartDeployment",
        "appconfig:GetDeployment",
        "appconfig:StopDeployment"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
    "Action": [
        "codecommit:GetRepository"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codedeploy:*"
      ],
      "Resource": "*"
    },
    {
        "Action": [
          "ecs:*",
          "events:DescribeRule",
          "events:DeleteRule",
          "events:ListRuleNamesByTarget",
          "events:ListTargetsByRule",
          "events:PutRule",
          "events:PutTargets",
          "events:RemoveTargets",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfiles",
          "iam:ListRoles",
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:FilterLogEvents"
        ],
        "Resource": "*",
        "Effect": "Allow"
      },
      {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
          "*"
        ],
        "Condition": {
          "StringLike": {
            "iam:PassedToService": "ecs-tasks.amazonaws.com"
          }
        }
      },
      {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:iam::*:role/ecsInstanceRole*"
        ],
        "Condition": {
          "StringLike": {
            "iam:PassedToService": [
              "ec2.amazonaws.com",
              "ec2.amazonaws.com.cn"
            ]
          }
        }
      },
      {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:iam::*:role/ecsAutoscaleRole*"
        ],
        "Condition": {
          "StringLike": {
            "iam:PassedToService": [
              "application-autoscaling.amazonaws.com",
              "application-autoscaling.amazonaws.com.cn"
            ]
          }
        }
      },
      {
        "Effect": "Allow",
        "Action": "iam:CreateServiceLinkedRole",
        "Resource": "*",
        "Condition": {
          "StringLike": {
            "iam:AWSServiceName": [
              "ecs.amazonaws.com",
              "spot.amazonaws.com",
              "spotfleet.amazonaws.com"
            ]
          }
        }
      }
  ]
}
EOF
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.tags["Name"]}-codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.tags["Name"]}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": ["*"],
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecs:RunTask",
        "iam:PassRole"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": ["*"],
      "Action": [
        "logs:*",
        "events:*",
        "s3:ListObjects",
        "s3:GetObjectAcl",
        "s3:DeleteObject",
        "s3:PutObject",
        "s3:GetObject",
        "s3:GetBucketTagging",
        "s3:ListBucket",
        "s3:GetBucketPolicy",
        "s3:GetBucketAcl",
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation",
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ]
    }
  ]
}
EOF
}
