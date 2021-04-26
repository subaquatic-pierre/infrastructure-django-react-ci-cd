data "aws_region" "current" {}

module "frontend_pipeline" {
  source = "./frontend"

  aws_account_id           = var.aws_account_id
  prefix                   = "${var.tags["Name"]}-frontend"
  frontend_site_bucket     = var.frontend_site_bucket
  frontend_cf_distribution = var.frontend_cf_distribution
  tags                     = var.tags

  github_token   = var.github_token
  github_account = var.github_account
  github_repo    = var.frontend_github_repo

  build_secrets = var.build_secrets

  codebuild_role    = aws_iam_role.codebuild_role.arn
  codepipeline_role = aws_iam_role.codepipeline_role.arn
}

module "api_pipeline" {
  source = "./api"

  aws_account_id = var.aws_account_id
  prefix         = "${var.tags["Name"]}-api"
  tags           = var.tags

  github_token   = var.github_token
  github_account = var.github_account
  github_repo    = var.api_github_repo

  subnet_ids = var.subnet_ids
  region     = data.aws_region.current.name

  build_secrets = var.build_secrets

  codebuild_role    = aws_iam_role.codebuild_role.arn
  codepipeline_role = aws_iam_role.codepipeline_role.arn
  api_ecr_repo_url  = var.api_ecr_repo_url
}
