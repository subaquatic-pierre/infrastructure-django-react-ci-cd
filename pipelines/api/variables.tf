variable "aws_account_id" {}
variable "prefix" {}
variable "tags" {}

variable "github_token" {}
variable "github_account" {}
variable "github_repo" {}

variable "subnet_ids" {}
variable "region" {}

variable "build_secrets" {
  type        = map(string)
  description = "All secrets used in building images"
}


variable "codebuild_role" {}
variable "codepipeline_role" {}
variable "api_ecr_repo_url" {}

