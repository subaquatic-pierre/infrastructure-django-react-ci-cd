resource "aws_ecs_cluster" "api_cluster" {
  name               = "${var.prefix}-cluster"
  capacity_providers = [aws_ecs_capacity_provider.api_capacity_provider.name]
  tags               = var.tags
}

resource "aws_ecs_capacity_provider" "api_capacity_provider" {
  name = "${var.tags["Name"]}-api-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.api_asg.arn

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

# update file container-def, so it's pulling image from ecr
resource "aws_ecs_task_definition" "api_task_definition" {
  family = var.prefix
  container_definitions = templatefile("${path.module}/container-definitions/container-def.json", {
    LOG_GROUP   = aws_cloudwatch_log_group.ecs_log_group.name,
    ECR_APP_URI = var.ecr_app_uri,
  })
  network_mode = "bridge"
  tags         = var.tags
}

resource "aws_ecs_service" "api_service" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.api_cluster.id
  task_definition = aws_ecs_task_definition.api_task_definition.arn
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_target_group.arn
    container_name   = "api"
    container_port   = 80
  }

  launch_type = "EC2"
  depends_on  = [aws_lb_listener.api_https_listener]
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/${var.tags["Project"]}/ecs/api"
  tags = var.tags
}
