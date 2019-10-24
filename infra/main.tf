provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "ausseabed-processing-pipeline-tf-infra"
    key = "terraform/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

#resource "aws_sfn_state_machine" "ausseabed-processing-pipeline" {
#  name = "ausseabed-processing-pipeline"
#  role_arn = ""
#}

module "networking" {
    source       = "./networking"
  vpc_cidr     = "${var.vpc_cidr}"
  public_cidrs = "${var.public_cidrs}"
  accessip     = "${var.accessip}"
}

module "compute" {
    source       = "./compute"
  fargate_cpu     = "${var.fargate_cpu}"
  fargate_memory = "${var.fargate_memory}"
  app_image     = "${var.app_image}"
}

module "ancillary" {
  source = "./ancillary"
}
