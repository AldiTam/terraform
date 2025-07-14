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
3. Run ```terraform apply``` to create the S3 bucket and DynamoDB table
4. Update the Terraform configuration to use the remote backend with the S3 bucket and DynamoDB table
5. Re-run ```terraform init``` to import the state into the new remote backend

Note: 
* S3 Bucket is used as the storage, wheras DynamoDB is used for locking to prevent multiple users running **terraform apply**
* Create a local backend first, before we can migrate to S3 Backend
 
```
terraform {
  #############################################################
  ##AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ##YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ##TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  backend "s3" {
    bucket         = "aldi-tf-state"
    key            = "03-basics/import-bootstrap/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true

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
```
### Crete Simple Web Application Architecture on AWS
1. Set up your Terraform Backend in S3 Bucket + DynamoDB.

2. Create a **main.tf** file and configure the backend definition:

The backend configuration goes within the top level **terraform {}** block.
```
terraform {
  # Assumes s3 bucket and dynamo DB table already set up
  # See /code/03-basics/aws-backend
  backend "s3" {
    bucket         = "aldi-tf-state"
    key            = "03-basics/web-app/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
```
3. Configure the AWS provider:
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

4. Create EC2 Instances:
The following configuration defines two virtual machines with a basic python webserver that will be executed upon startup (by placing the commands within the user_data block).

We also need to define a security group so that we will be able to allow inbound traffic to the instances.
```
resource "aws_instance" "instance_1" {
  ami             = "ami-0229b8f55e5178b65" # Ubuntu 20.04 LTS // eu-central-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}

resource "aws_instance" "instance_2" {
  ami             = "ami-0229b8f55e5178b65" # Ubuntu 20.04 LTS // eu-central-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 2" > index.html
              python3 -m http.server 8080 &
              EOF
}
```

5. Create an S3 Bucket:
```
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "aldi-web-app-data"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

6. Reference Default VPC and Subnet
To keep things simple, this configuration is deployed into a default VPC and Subnet.

Since these should already exist, we use the **data** object rather than the **resource** object so that terraform can retrieve information about them, but not manage them directly.
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

7. Define Security Groups and Rules
```
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

8. Set Up Load Balancer
We have two virtual machines and want to split traffic between them. We can do this with a load balancer. We configure the load balancer behavior and attach the two EC2 instances to it.

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port = 80
  protocol = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "instances" {
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

}

resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
}

9. Configure Route 53 for DNS
Rather than access the application with the auto-generated domain of the load balancer, instead we define a Route 53 DNS record to use a domain of our choosing.

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "learneveryday.duckdns.org"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

10.  Create an RDS instance

Our application does not actually use the RDS instance, but we provision one to demonstrate how because most web applications will need a database of some kind.

11. Terraform Initialize, Plan, and Apply the Configuration

12. Test the Web Application
Access the load balancer's DNS name or your domain to check if the instances are working and load balancing is functioning properly.

13. Destroy the Resources
Run **terraform destroy** to clean up the resources.

## 4. Variables and Outputs

### Terraform Variables and Outputs Application
In this section, we will demonstrate how to use Terraform variables and outputs in the sample web application configuration shown earlier in the course to make it more flexible and generalizable.

1. **Local Variable**:  Declare local variables in your main.tf file to define values that are scoped within the project and reused throughout the configuration (but cannot be passed in at runtime).

```
locals {
  example_variable = "example_value"
}

2. **Input Variables:** Define input variables in a separate `variables.tf` file or within your `main.tf` file. These variables allow you to configure and change values at runtime.

For example, we can define the following variables associated with our EC2 instacnes:

variable "ami" {
  description = "Amazon machine image to use for ec2 instance"
  type        = string
  default     = "ami-0229b8f55e5178b65" # Ubuntu 20.04 LTS // eu-central-1
}

variable "instance_type" {
  description = "ec2 instance type"
  type        = string
  default     = "t2.micro"
}
```
After defining the variables, we then reference them within the resource configuration using **var.VARIABLE_NAME**
```
resource "aws_instance" "instance_1" {
  ami             = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instances.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World 1" > index.html
              python3 -m http.server 8080 &
              EOF
}
```
3. **TFVARS Files**: Create a terraform.tfvars file to store non-sensitive values for your input variables:
```
bucket_prefix = "devops-directive-web-app-data"
domain        = "devopsdeployed.com"
db_name       = "mydb"
db_user       = "user"
# For sensitive variables, pass them at runtime instead of storing them in the .tfvars file.
# db_pass = "password"
```

4. **Outputs**: Add output variables to your configuration to provide access to important information such as IP addresses:
```
output "instance_1_ip_addr" {
  value = aws_instance.instance_1.public_ip
}
```
5. **Deploy Configuration**: Perform the usual terraform init, terraform plan, and terraform apply steps to provision the infrastructure.
```
terraform apply -var "db_user=my_user" -var "db_pass=something_super_secure"
```
By using variables in this way, we can deploy multiple copies of a similar but slightly different web application.

Additionally, we can create staging and production environments simply by configuring different variable values within the terraform.tfvars file.

Remember not to store sensitive values like passwords in .tfvars file; instead, pass them at runtime or use an external secrets manager.

## 5: Additional HCL Features
