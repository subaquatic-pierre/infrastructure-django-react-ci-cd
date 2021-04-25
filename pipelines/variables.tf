variable "aws_account_id" {}
variable "tags" {}
variable "github_token" {}
variable "github_account" {}
variable "api_ecr_repo_url" {}
variable "frontend_github_repo" {}
variable "api_github_repo" {}

variable "build_secrets" {
  type        = map(string)
  description = "All secrets used in building images"
}

# From vpc module
variable "subnet_ids" {}

# From frontend module
variable "frontend_site_bucket" {}
variable "frontend_cf_distribution" {}
