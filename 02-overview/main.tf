
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "test" {
  ami           = "ami-0229b8f55e5178b65" # Ubuntu 20.04 LTS // eu-central-1
  instance_type = "t2.micro"
}