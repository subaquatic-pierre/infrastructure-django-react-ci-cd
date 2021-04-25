resource "aws_codebuild_project" "api_build" {
  name          = "${var.prefix}-codebuild"
  service_role  = var.codebuild_role
  badge_enabled = false
  tags          = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_bucket.bucket}/cache"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = templatefile("${path.module}/buildspec.yml", {
      ACCOUNT_ID              = var.aws_account_id
      REPOSITORY_URI          = var.api_ecr_repo_url
      REGION                  = var.region
      CONTAINER_NAME          = "app"
      DB_NAME                 = var.build_secrets["DB_NAME"]
      DB_USER                 = var.build_secrets["DB_USER"]
      DB_PASSWORD             = var.build_secrets["DB_PASSWORD"]
      DB_HOST                 = var.build_secrets["DB_HOST"]
      DB_PORT                 = var.build_secrets["DB_PORT"]
      EMAIL                   = var.build_secrets["EMAIL"]
      SECRET_KEY              = var.build_secrets["SECRET_KEY"]
      DEBUG                   = var.build_secrets["DEBUG"]
      ALLOWED_HOSTS           = var.build_secrets["ALLOWED_HOSTS"]
      AWS_MEDIA_BUCKET_NAME   = var.build_secrets["AWS_MEDIA_BUCKET_NAME"]
      AWS_STORAGE_BUCKET_NAME = var.build_secrets["AWS_STORAGE_BUCKET_NAME"]
      AWS_ACCESS_KEY_ID       = var.build_secrets["AWS_ACCESS_KEY_ID"]
      AWS_SECRET_ACCESS_KEY   = var.build_secrets["AWS_SECRET_ACCESS_KEY"]
      DOCKER_USERNAME         = var.build_secrets["DOCKER_USERNAME"]
      DOCKER_PASSWORD         = var.build_secrets["DOCKER_PASSWORD"]
    })
  }
}
