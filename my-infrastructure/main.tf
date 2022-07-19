terraform {
  cloud {
    organization = "evinracher"
    workspaces {
      name = "devops-course"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "az_a" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_subnet" "az_b" {
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_instance" "server1" {
  ami           = "ami-0ddf424f81ddb0720"
  instance_type = "t2.micro"
  user_data     = file("./user-data.sh")
  tags = {
    Name = "server1"
  }
}

# resource "aws_instance" "server2" {
#   ami                    = "ami-0ddf424f81ddb0720"
#   instance_type          = "t2.micro"
#   user_data              = file("./user-data.sh")
#   tags = {
#     Name = "server2"
#   }
# }

# resource "aws_instance" "server3" {
#   ami                    = "ami-0ddf424f81ddb0720"
#   instance_type          = "t2.micro"
#   user_data              = file("./user-data.sh")
#   tags = {
#     Name = "server3"
#   }
# }

resource "aws_lb" "alb" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]

}

resource "aws_security_group" "lb_sg" {
  name = "alb-sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80 access from outside"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 22 access from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 8080 access from servers"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Port 80 access from servers"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "devops-course-alb-target-group"
  port     = 80
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = "8080"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "server1" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server1.id
  port             = "8080"
}

# resource "aws_lb_target_group_attachment" "server2" {
#   target_group_arn = aws_lb_target_group.this.arn
#   target_id        = aws_instance.server2.id
#   port             = "8080"
# }

# resource "aws_lb_target_group_attachment" "server3" {
#   target_group_arn = aws_lb_target_group.this.arn
#   target_id        = aws_instance.server3.id
#   port             = "8080"
# }
