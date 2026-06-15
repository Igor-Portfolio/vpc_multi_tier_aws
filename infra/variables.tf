variable "aws_region" {
  description = "AWS region used by the AWS provider."
  type        = string
  default     = "eu-south"
}

variable "project_name" {
  description = "Project name used for tags and resource naming."
  type        = string
  default     = "multi-tier-vpc-infra"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Globally unique name for the private S3 bucket."
  type        = string
  
  default = "multi-tier-vpc-infra-html"
}

variable "force_destroy_bucket" {
  description = "If true, Terraform can delete the bucket even when it contains objects. Use carefully."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

var "lb_name" {
  type = string 
  default = "lb_app"
}