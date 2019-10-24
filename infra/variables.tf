variable "aws_region" {}

#------ storage variables



#-------networking variables

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = "list"
}

variable "accessip" {}

#-------compute variables

variable "fargate_cpu"{}
variable "fargate_memory"{}
variable "app_image"{}
