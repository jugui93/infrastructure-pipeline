#Input variable definitions

variable "region" {
  description = "The AWS region where the infraestruture will be deployed"
  type        = string
  default     = "eu-central-1"
}

variable "availability_zone" {
  description = "The availability zone where the infraestruture will be deployed"
  type        = list(string)
  default     = ["eu-central-1a","eu-central-1b"]
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "publicCIDR" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "environment" {
  description = "The environment where the infraestructure will be deployed"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "The instance type to be used for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "instance_AMI" {
  description = "The AMI ID of the instance to be launched"
  type        = string
  default     = "ami-05d34d340fb1d89e5"
}

variable "allowed_ports" {
  description = "A list of allowed ports"
  type        = list(string)
  default     = ["80", "443", "22", "8080"]
}
