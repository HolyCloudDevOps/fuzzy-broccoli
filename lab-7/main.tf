terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.4.0"

  backend "s3" {
    bucket         = "tf-backend-fuzzy-broccoli"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.forall.id]
  user_data = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_instance.app, aws_instance.db ]

  tags = {
    Name = "lab-7-${count.index}-${timestamp()}"
  }
  
}


resource "aws_instance" "app" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.forall.id]
  user_data = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_instance.db ]

  tags = {
    Name = "lab-7-${count.index}-${timestamp()}"
  }
  
}

resource "aws_instance" "db" {
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.forall.id]
  user_data = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "lab-7-${count.index}-${timestamp()}"
  }
  
}

resource "aws_security_group" "forall" {
  name        = "new-web-server"
  description = "SG for my WebServer"
  //vpc_id      = "CHANGE_TO_YOUR_DEFAULT_VPC"

  dynamic "ingress" {
    for_each = ["80", "8080", "443", "500"]
    content {
      description = "Allow ports"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServer"
  }
}
