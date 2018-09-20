# Terraform AWeSome 

This is an example configuration for some AWS resources to demonstrate the AWeSomeness of Terraform.  It will create a VPC, an application load balancer (ALB), and a few EC2 in multiple AZs running an nginx docker image, and will spin up in just a few minutes.

## !!!WARNINGS!!!
WARNING: THIS WILL COST YOU MONEY!!!  Utilize at your own risk, and since this example is intended to be disposable, use `terraform destroy` when you are finished checking it out.

WARNING: DO NOT EDIT RESOURCES MANUALLY IN AWS ONCE YOU HAVE APPLIED A TERRAFORM PLAN!!! If the resources become out of sync with the state, it can be difficult to recover, which could result in resources not being created, updated, or destroyed in the way that you think they should be.   

## Setup

1. Install Terraform (v0.11.8 at time of writing)
2. Copy file, `terraform.tfvars.example` to `terraform.tfvars`
3. Update values in `terraform.tfvars` to match your desired configuration
4. Init, plan, apply, destroy!

## Running

`terraform init`

`terraform plan -out plan`

`terraform apply plan`

`terraform destroy`

