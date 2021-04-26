resource "aws_codepipeline" "frontend_pipeline" {
  name     = "${var.prefix}-pipeline"
  role_arn = var.codepipeline_role

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_account
        OAuthToken = var.github_token

        Repo   = var.github_repo["name"]
        Branch = var.github_repo["prod_branch"]
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "${var.prefix}-codebuild"
      }
    }
  }

  tags = var.tags
}


