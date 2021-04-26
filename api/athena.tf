data "aws_caller_identity" "main" {}
data "aws_region" "main" {}

data "template_file" "lb_logs" {
  template = file("${path.module}/templates/create_table.sql.tpl")

  vars = {
    bucket     = aws_s3_bucket.lb_logs.id
    account_id = data.aws_caller_identity.main.account_id
    region     = data.aws_region.main.name
  }
}

resource "aws_athena_database" "lb_logs" {
  name   = "django_react_ci_cd_project"
  bucket = aws_s3_bucket.lb_logs.id
}

resource "aws_athena_named_query" "lb_logs" {
  name     = "${var.tags["Project"]}-create-table"
  database = aws_athena_database.lb_logs.name
  query    = data.template_file.lb_logs.rendered
}
