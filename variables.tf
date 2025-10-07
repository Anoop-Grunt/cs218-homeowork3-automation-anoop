variable "region" {
  type    = string
  default = "us-west-2"
}

variable "name" {
  description = "Base name for resources (prefix)"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.0.0/28"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.0.16/28"
}

variable "instance_type_public" {
  type    = string
  default = "t3.micro"
}

variable "instance_type_private" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "public_subnet_az" {
  description = "Availability Zone for the public subnet"
  type        = string
  default = "us-west-2a"
}

variable "private_subnet_az" {
  description = "Availability Zone for the private subnet"
  type        = string
  default = "us-west-2b"
}

variable "ami" {
  description = "The image to put on the ec2"
  type        = string
}
