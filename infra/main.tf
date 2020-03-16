provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "ausseabed-processing-pipeline-tf-infra"
    key    = "terraform/terraform.tfstate"
    region = "ap-southeast-2"
  }
}


module "networking" {
  source       = "./networking"
  vpc_cidr     = var.vpc_cidr
  public_cidrs = var.public_cidrs
  accessip     = var.accessip
  private_cidrs = var.private_cidrs
  jumpboxip     = var.jumpboxip
}

module "compute" {
  source                      = "./compute"
  fargate_cpu                 = var.fargate_cpu
  fargate_memory              = var.fargate_memory
  caris_caller_image                   = var.caris_caller_image
  startstopec2_image                   = var.startstopec2_image
  gdal_image = var.gdal_image
  mbsystem_image = var.mbsystem_image
  pdal_image = var.pdal_image
  ecs_task_execution_role_arn = module.ancillary.ecs_task_execution_role_arn
  private_subnets  = module.networking.private_subnets
  private_sg  = module.networking.private_sg
  public_subnets  = module.networking.public_subnets
  public_sg  = module.networking.public_sg
}

module "ancillary" {
  source = "./ancillary"
  ausseabed-processing-pipeline = module.pipelines.ausseabed-processing-pipeline-ga
}

module "pipelines" {
  source = "./pipelines"
  ausseabed_sm_role=module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn
  aws_ecs_cluster_arn=module.compute.aws_ecs_cluster_arn
  aws_ecs_task_definition_gdal_arn=module.compute.aws_ecs_task_definition_gdal_arn
  aws_ecs_task_definition_mbsystem_arn=module.compute.aws_ecs_task_definition_mbsystem_arn
  aws_ecs_task_definition_pdal_arn=module.compute.aws_ecs_task_definition_pdal_arn
  aws_ecs_task_definition_caris_sg=module.networking.aws_ecs_task_definition_caris_sg
  aws_ecs_task_definition_caris_subnet=module.networking.aws_ecs_task_definition_caris_subnet

  aws_ecs_task_definition_caris_version_arn=module.compute.aws_ecs_task_definition_caris-version_arn
  aws_ecs_task_definition_startstopec2_arn=module.compute.aws_ecs_task_definition_startstopec2_arn
  local_storage_folder=var.local_storage_folder
}

module "get_resume_lambda_function" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "getResumeFromStep"
  handler       = "getResumeFromStep.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30
  role          = module.ancillary.getResumeFromStep_role
  enabled       = true

  # Enable build functionality.
  build_mode = "FILENAME"
  source_dir = "${path.module}/src/lambda/resume_from_step"
  filename   = "getResumeFromStep.py"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}


module "identify_instrument_lambda_function" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "identify_instrument_files"
  handler       = "identify_instrument_files.lambda_handler"
  runtime       = "python3.6"
  timeout       = 300
  role          = module.ancillary.identify_instrument_files_role
  enabled       = true

  # Enable build functionality.
  build_mode = "FILENAME"
  source_dir = "${path.module}/src/lambda/identify_instrument_files"
  filename   = "identify_instrument_files.py"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}






#carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface ${var.local_storage_folder}\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar --threshold-type STANDARD_DEVIATION --scalar 1.6 file:///${var.local_storage_folder}\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips
