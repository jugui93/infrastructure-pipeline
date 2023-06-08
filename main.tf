terraform {
  backend "s3" {
  bucket = "e9a02333-d570-4926-b381-f3c96c1c4478-backend"
  key = "infrastructure/terraform.tfstate"
  region = "eu-central-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnetA" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.publicCIDR[0]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[0]
}

resource "aws_subnet" "public_subnetB" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.publicCIDR[1]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone[1]
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnetA.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "instance" {
  name_prefix = "instance-"
  vpc_id      = aws_vpc.main.id
  
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance-sg"
  }
}

resource "aws_lb" "lb" {
  name = "app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.instance.id]
  subnets = [aws_subnet.public_subnetA.id, aws_subnet.public_subnetB.id]

  access_logs {
    bucket = "39b0a696-a61f-465d-aca4-c995bafb7c14-load-balancer-bucket"
    prefix = "lb"
    enabled= true
  }

  tags = {
    Name = "load-balancer"
  }
}

resource "aws_lb_target_group" "group" {
  name = "group-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
}

resource "aws_lb_listener" "lb" {
  load_balancer_arn= aws_lb.lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.group.arn
  }
}

resource "aws_autoscaling_attachment" "as_config" {
  autoscaling_group_name = aws_autoscaling_group.as_config.name
  lb_target_group_arn = aws_lb_target_group.group.arn
}

resource "aws_launch_configuration" "as_config" {
  name_prefix = "lc-http-"
  image_id = var.instance_AMI
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "as_config" {
  min_size = 1
  max_size = 4
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.as_config.name
  vpc_zone_identifier = [aws_subnet.public_subnetA.id, aws_subnet.public_subnetB.id]
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "app_scale_down"
  autoscaling_group_name = aws_autoscaling_group.as_config.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 120
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "app_scale_up"
  autoscaling_group_name = aws_autoscaling_group.as_config.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 120
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_description   = "Monitors CPU utilization for as_config ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "app_scale_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "10"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_config.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_description   = "Monitors CPU utilization for as_config ASG"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  alarm_name          = "app_scale_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = "20"
  evaluation_periods  = "2"
  period              = "120"
  statistic           = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.as_config.name
  }
}