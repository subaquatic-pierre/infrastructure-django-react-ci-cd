resource "aws_codepipeline" "api_pipeline" {
  name     = "${var.prefix}-pipeline"
  role_arn = var.codepipeline_role
  tags     = var.tags

  artifact_store {
    location = aws_s3_bucket.codebuild_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection
        FullRepositoryId = "subaquatic-pierre/${var.github_repo["name"]}"
        BranchName       = var.github_repo["prod_branch"]
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
      output_artifacts = ["imagedefinitions"]

      configuration = {
        ProjectName = "${var.prefix}-codebuild"
      }
    }
  }

  stage {
    name = "Production"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["imagedefinitions"]
      version         = "1"

      configuration = {
        ClusterName = "${var.prefix}-cluster"
        ServiceName = "${var.prefix}-service"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

