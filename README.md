# terraform

This project is based on https://courses.devopsdirective.com/terraform-beginner-to-pro/lessons/00-introduction/01-main
https://github.com/sidpalas/devops-directive-terraform-course

## 📖 Description
In this project we are going to:

1. Terraform Overview and Set Up

2. Basic Terraform Usage: Explore the basics of using Terraform with AWS.

3. Variables and Outputs: Dive into using variables and outputs in Terraform configurations.

4. HashiCorp Configuration Language (HCL) Features: Learn about HCL, the language used by Terraform, and discover its powerful features for managing cloud infrastructure.

5. Organizing Projects and Reusable Modules: Learn best practices for organizing Terraform projects and creating reusable modules for extensibility and applicability across different environments.

6. Managing Multiple Environments: Understand how to manage multiple environments, such as staging, development, and production, using Terraform.

7. Testing Infrastructure as Code Configurations: Discover techniques for testing your Infrastructure as Code configurations to ensure reliability and stability.

8. Developer Workflows and Automation: Explore various developer workflows and learn how to automate deployments using tools like GitHub Actions.

## 1. Terraform Overview and Set up
What is Terraform? Terraform is a powerful Infrastructure as Code (IaC) tool that allows you to build, change, and version infrastructure safely and easily. It can be used in conjunction with other IaC tools to create powerful and flexible infrastructure management solutions.

Terraform + Configuration Management Tools (e.g., Ansible):

Terraform provisions virtual machines
Ansible installs and configures dependencies inside virtual machines.
Terraform + Templating Tools (e.g., Packer):

Terraform provisions servers.
Packer builds the image from which virtual machines are created.
Terraform + Orchestration Tools (e.g., Kubernetes):

Terraform provisions Kubernetes clusters.
Kubernetes defines how the application is deployed and managed on the cloud resources.

## 2. Basic Terraform Usage: Explore the basics of using Terraform with AWS.

1. Create a file named main.tf with the following content:

```python
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-092ff8e60e2d51e19" # Ubuntu 20.04 LTS // us-east-1
  instance_type = "t2.micro"
}
```

Initialize Terraform in the directory containing main.tf by running:
terraform init
. This sets up the backend and state storage.
Run terraform plan to view the changes Terraform will make to your infrastructure.
Run terraform apply to create the specified resources. Confirm the action when prompted.
To clean up resources and avoid unnecessary costs, run terraform destroy and confirm the action when prompted.


Description

## Installation

## Softwares

##
