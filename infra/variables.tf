variable "aws_region" {}

variable "stack_name" {
  description = "The name of our application"
  default     = "seabed"
}

variable "owner" {
  description = "A group email address to be used in tags"
  default     = "david.hudson@ga.gov.au"
}

variable "environment" {}


#------ storage variables

variable "local_storage_folder" {}

#-------networking variables

variable "vpc_cidr" {}

variable "public_cidrs" {
  type = list(string)
}

variable "accessip" {}
variable "jumpboxip" {}

variable "private_cidrs" {
  type = list(string)
}

#-------compute variables

variable "fargate_cpu"{}
variable "fargate_memory"{}
variable "caris_caller_image"{}
variable "startstopec2_image"{}

variable "gdal_image"{}
variable "mbsystem_image"{}
variable "pdal_image"{}


