resource "aws_codestarconnections_connection" "django_react_github_connection" {
  name          = "${var.tags["Project"]}-connection"
  provider_type = "GitHub"
}
