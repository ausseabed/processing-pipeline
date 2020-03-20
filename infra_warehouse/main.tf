provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "ausseabed-processing-pipeline-tf-infra"
    key    = "terraform/terraform-geoserver.tfstate"
    #key    = "terraform/terraform-server.tfstate"
    region = "ap-southeast-2"
  }
}


module "networking" {
  source       = "./networking"
  vpc_cidr     = "${var.vpc_cidr}"
  public_cidrs = "${var.public_cidrs}"
  accessip     = "${var.accessip}"
}


module "ancillary" {
  source = "./ancillary"
}

module "geoserver" {
  source       = "./geoserver"
  server_cpu                 = var.server_cpu
  server_memory              = var.server_memory
  ecs_task_execution_role_svc_arn = module.ancillary.ecs_task_execution_role_svc_arn
  public_subnets  = module.networking.public_subnets
  public_sg = module.networking.public_sg
  geoserver_image = var.geoserver_image
  geoserver_initial_memory = var.geoserver_initial_memory
  geoserver_maximum_memory = var.geoserver_maximum_memory
  geoserver_admin_password = var.geoserver_admin_password
  aws_ecs_lb_target_group_geoserver_arn = module.networking.aws_ecs_lb_target_group_geoserver_arn
}

module "postgres" {
  source = "./postgres"
  aws_region = var.aws_region
  postgres_admin_password = var.postgres_admin_password 
  postgres_server_spec = var.postgres_server_spec
  public_subnets = module.networking.public_subnets
  public_sg = module.networking.public_sg 
}

#module "mapserver" {
#  source       = "./mapserver"
#  server_cpu                 = "${var.server_cpu}"
#  server_memory              = "${var.server_memory}"
#  ecs_task_execution_role_svc_arn = "${module.ancillary.ecs_task_execution_role_svc_arn}"
#  public_subnets  = "${module.networking.public_subnets}"
#  public_sg = "${module.networking.public_sg}"
#}
