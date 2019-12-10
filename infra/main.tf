provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "ausseabed-processing-pipeline-tf-infra"
    key    = "terraform/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

#resource "aws_sfn_state_machine" "" {
#  name = "ausseabed-processing-pipeline"
#  role_arn = ""
#}




module "networking" {
  source       = "./networking"
  vpc_cidr     = "${var.vpc_cidr}"
  public_cidrs = "${var.public_cidrs}"
  accessip     = "${var.accessip}"
  private_cidrs = "${var.private_cidrs}"
  jumpboxip     = "${var.jumpboxip}"
}

module "compute" {
  source                      = "./compute"
  fargate_cpu                 = "${var.fargate_cpu}"
  fargate_memory              = "${var.fargate_memory}"
  caris_caller_image                   = "${var.caris_caller_image}"
  startstopec2_image                   = "${var.startstopec2_image}"
  ecs_task_execution_role_arn = "${module.ancillary.ecs_task_execution_role_arn}"
  private_subnets  = "${module.networking.private_subnets}"
  private_sg  = "${module.networking.private_sg}"
  public_subnets  = "${module.networking.public_subnets}"
  public_sg  = "${module.networking.public_sg}"
}

module "ancillary" {
  source = "./ancillary"
  ausseabed-processing-pipeline = "${aws_sfn_state_machine.ausseabed-processing-pipeline_sfn_state_machine-ga}"
}

module "lambda_function" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "getResumeFromStep"
  handler       = "getResumeFromStep.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30
  role          = "${module.ancillary.getResumeFromStep_role}"
  enabled       = true

  # Enable build functionality.
  build_mode = "FILENAME"
  source_dir = "${path.module}/src/lambda/resume_from_step"
  filename   = "getResumeFromStep.py"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}







#carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar --threshold-type STANDARD_DEVIATION --scalar 1.6 file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips
