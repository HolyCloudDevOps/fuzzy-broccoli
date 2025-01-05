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
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = <<EOF
#!/bin/bash
apt update -y
apt install apache2 -y

MYIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "<h2>Webserver with Private IP: $MYIP</h2>" > /var/www/html/index.html

systemctl start apache2
systemctl enable apache2
EOF

  tags = {
    Name = "MyUbuntu Lab2"
  }

}


resource "aws_security_group" "web" {
  name        = "web-server"
  description = "SG for my WebServer"
  vpc_id      = "CHANGE_TO_YOUR_DEFAULT_VPC"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
