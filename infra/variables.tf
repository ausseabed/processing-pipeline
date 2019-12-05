variable "aws_region" {}

#------ storage variables



#-------networking variables

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = "list"
}

variable "accessip" {}
variable "jumpboxip" {}

variable "private_cidrs" {
  type = "list"
}

#-------compute variables

variable "fargate_cpu"{}
variable "fargate_memory"{}
variable "caris_caller_image"{}
variable "startstopec2_image"{}




