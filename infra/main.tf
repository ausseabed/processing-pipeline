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

#resource "aws_sfn_state_machine" "" {
#  name = "ausseabed-processing-pipeline"
#  role_arn = ""
#}


resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine" {
  name     = "ausseabed-processing-pipeline"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  definition = templatefile("ausseabed-processing-pipeline_sfn_state_machine", merge("${module.compute}","${module.networking}"))

}

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
  ecs_task_execution_role_arn = "${module.ancillary.ecs_task_execution_role_arn}"
}

module "ancillary" {
  source = "./ancillary"
}
