data "aws_ecr_repository" "api_app" {
  name = "django-graphql-api"
}

resource "aws_ecr_lifecycle_policy" "api_app" {
  repository = data.aws_ecr_repository.api_app.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
