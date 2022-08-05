# # this tells terraform to install/use the AWS provider
# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.16"
#     }
#   }
#   required_version = ">= 1.2.0"
# }

# # set the AWS region to use - you can change this, but then the AMI
# # below will have to change as well (since AMIs are region-specific)
# provider "aws" {
#   region = "us-east-2"
# }

# # we want a micro EC2 instance!
# resource "aws_instance" "app_server" {
#   ami           = "ami-0b59bfac6be064b78"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "ExampleAppServerInstance"
#   }
# }
