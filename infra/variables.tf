variable "aws_region" {
  description = "AWS region used by the AWS provider."
  type        = string
  default     = "eu-west-3"
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

variable "lb_name" {
  type = string 
  default = "lb_app"
}

variable "db_username" {
  type = string
  description = "User of DataBase"
  sensitive = true
} 

variable "db_password" {
  type = string
  description = "Password of DataBase"
  sensitive = true
} 

 variable "number_azs" {
  type = number
  default = 2
 }

variable "azs" {
  type = list(string)
  default = []
  default = [data.availability_zone[0], data.availability_zone[1]]
} 

locals {
  public_cidrs = [for i in range(var.vpc_cidr) : cidrsubnet(var.vpc_cidr,8, i)]
  private_cidrs = [for i in range(var.vpc_cidr): cidrsubnet(var.vpc_cidr,8 i * range(var.vpc_cidr)]
  db_cidrs = [for i in range(var.vpc_cidr), 8, i * range(var.vpc_cidr) * 2]
}

locals {
  azs = slice(data.availability_zone)
}