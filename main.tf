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

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.publicCIDR[0]
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
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
  subnet_id      = aws_subnet.public.id
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
  subnets = [aws_subnet.public.id]

  enable_deletion_protection = true 

  access_logs {
    bucket = aws_s3_bucket.lb_logs.id
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
    target_group_arn = aws_lb.lb.arn
  }
}

resource "aws_lb_target_group_attachment" "group" {
  target_group_arn = aws_lb_target_group.group.arn
  target_id = aws_instance.http_server.id
  port = 80
}

resource "aws_instance" "http_server" {
  ami                    = var.instance_AMI
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = <<-EOF
                  #!/bin/bash
                  sudo apt-get update
                  sudo apt-get install -y apache2
                  sudo systemctl start apache2
                  EOF

  tags = {
    Name = "http_server"
  }
}
