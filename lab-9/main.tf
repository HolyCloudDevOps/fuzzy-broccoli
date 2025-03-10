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

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"
} 

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.prod.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Subnet 1"
    Info = "AZ: ${data.aws_availability_zones.available.names[0]} in Region: ${data.aws_region.current.description}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.prod.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Subnet 2"
        Info = "AZ: ${data.aws_availability_zones.available.names[1]} in Region: ${data.aws_region.current.description}"
  }
}



output "region_name" {
  value = data.aws_region.current.name
}

output "region_description" {
  value = data.aws_region.current.description
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "AZ" {
  value = data.aws_availability_zones.available.names
}