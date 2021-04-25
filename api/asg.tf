data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.prefix}-ec2-sg"
  description = "Allow only VPC traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr, "0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_launch_configuration" "api_launch_config" {
  name          = "${var.prefix}-api-api"
  image_id      = data.aws_ami.amazon_linux.id
  key_name      = "AWS-EC2"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  security_groups             = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=${var.prefix}-cluster" >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "api_asg" {
  name                      = "${var.prefix}-asg"
  launch_configuration      = aws_launch_configuration.api_launch_config.name
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = var.subnet_ids

  target_group_arns = [aws_lb_target_group.api_target_group.arn]
  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
