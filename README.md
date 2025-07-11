# Infrastructure as Code with Terraform

This project is based on https://courses.devopsdirective.com/terraform-beginner-to-pro/lessons/00-introduction/01-main
https://github.com/sidpalas/devops-directive-terraform-course

## Description
In this project we are going to:

1. Infrastructure as Code

2. Terraform Overview and Set Up

3. Basic Terraform Usage: Explore the basics of using Terraform with AWS.

4. Variables and Outputs in Terraform configurations.

5. HashiCorp Configuration Language (HCL) Features: Learn about HCL, the language used by Terraform, and discover its powerful features for managing cloud infrastructure.

6. Organizing Projects and Reusable Modules: Learn best practices for organizing Terraform projects and creating reusable modules for extensibility and applicability across different environments.

7. Managing Multiple Environments: Understand how to manage multiple environments, such as staging, development, and production, using Terraform.

8. Testing Infrastructure as Code Configurations: Discover techniques for testing your Infrastructure as Code configurations to ensure reliability and stability.

9. Developer Workflows and Automation: Explore various developer workflows and learn how to automate deployments using tools like GitHub Actions.

*All correspoing **main.tf** files can be found in each subfolders.

## 1. Infrastructure as Code

### Infrastructure as Code (IaC) Overview

Three Main Approaches for Provisioning Cloud Resources:

Cloud Console: A graphical user interface provided by cloud providers, allowing users to interact with and manage cloud services.

API or Command-Line Interface: A method of interacting with cloud services programmatically, allowing for more efficient and automated management.

Infrastructure as Code: Defining your entire infrastructure within your codebase, offering better control, visibility, and consistency across environments.


### Categories of Infrastructure as Code Tools:

1. Ad-hoc scripts: Basic scripts that make API calls to provision infrastructure resources (e.g., shell scripts).

2. Configuration management tools: Tools like Ansible, Puppet, and Chef, designed to manage software and infrastructure configuration.

3. Server templating tools: Tools for building server templates, such as Amazon Machine Images (AMIs) or virtual machine images.

4. Orchestration tools: Tools like Kubernetes, which focus on deploying applications and managing containers.

5. Provisioning tools: Tools like Terraform, which focus on provisioning cloud resources using a declarative approach.

## 2. Terraform Overview and Set up
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

1. Create a file named main.tf with the following content:

```
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

resource "aws_instance" "example" {
  ami           = "ami-0229b8f55e5178b65" # Ubuntu 20.04 LTS // eu-central-1
  instance_type = "t2.micro"
}
```

Initialize Terraform in the directory containing main.tf by running:
```
terraform init
```
This sets up the backend and state storage. Next, run
```
terraform plan
```
to view the changes Terraform will make to your infrastructure. Run
```
terraform apply
```
to create the specified resources. Confirm the action when prompted.
To clean up resources and avoid unnecessary costs, run
```
terraform destroy
```

By following these steps, we have set up Terraform, authenticated with AWS, and created a basic configuration to provision a virtual machine on AWS!

## 3. Basic Terraform Usage
### The General Sequence of Terraform Commands:

1. **terraform init**: Initializes project
2. **terraform plan**: Checks the configuration against the current state and generates a plan of what will happen
3. **terraform apply**: Applies the plan to create or update the infrastructure
4. **terraform destroy**: Removes resources when no longer needed. Use with caution as it permanently deletes resources.

### Storing the State File:
- Local Backend: The state file is stored within the working directory of the project

- Remote Backend: The state file is stored in a remote object store or a managed service like Terraform Cloud

### Terraform plan Command
- Compares the desired state (Terraform configuration) with the actual state (Terraform state file)
- Identifies any discrepancies between the two states
- Outputs the differences and the actions needed to reconcile the states

### Terraform apply Command
- Executes the actions identified in the Terraform Plan command
- Creates, modifies, or deletes resources as needed to match the desired state
- Updates the Terraform state file to reflect the changes

### Terraform destroy Command
- Removes all resources associated with the Terraform configuration
- Use with caution, as it permanently deletes resources

### Bootstrapping Process for AWS S3 Backend

1. Create a Terraform configuration without a remote backend (defaults to a local backend)
2. Define the necessary AWS resources: S3 bucket and DynamoDB table with a hash key named "LockID"
3. Run '''terraform apply''' to create the S3 bucket and DynamoDB table
4. Update the Terraform configuration to use the remote backend with the S3 bucket and DynamoDB table
5. Re-run '''terraform init''' to import the state into the new remote backend

'''
terraform {
  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  # backend "s3" {
  #   bucket         = "devops-directive-tf-state" # REPLACE WITH YOUR BUCKET NAME
  #   key            = "03-basics/import-bootstrap/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-locking"
  #   encrypt        = true
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket        = "devops-directive-tf-state" # REPLACE WITH YOUR BUCKET NAME
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket        = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
} 
'''
### Crete Simple Web Application Architecture
1. Set up your Terraform Backend



## 4. Variables and Outputs
1. Set up terraform backend

2. 

3.  

4.


## Installation

## Softwares

##
