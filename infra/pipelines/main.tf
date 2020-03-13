locals {
  pipeline_vars = { 
    "caris_ip" = "172.31.11.235"
    "ausseabed_sm_role" = var.ausseabed_sm_role
    "aws_ecs_cluster_arn" = var.aws_ecs_cluster_arn
    "aws_ecs_task_definition_gdal_arn" = var.aws_ecs_task_definition_gdal_arn
    "aws_ecs_task_definition_caris_sg" = var.aws_ecs_task_definition_caris_sg
    "aws_ecs_task_definition_caris_subnet" = var.aws_ecs_task_definition_caris_subnet
    "aws_ecs_task_definition_mbsystem_arn" = var.aws_ecs_task_definition_mbsystem_arn
    "aws_ecs_task_definition_pdal_arn" = var.aws_ecs_task_definition_pdal_arn
    "aws_ecs_task_definition_caris_version_arn" = var.aws_ecs_task_definition_caris_version_arn
    "aws_ecs_task_definition_startstopec2_arn" = var.aws_ecs_task_definition_startstopec2_arn
    "local_storage_folder" = var.local_storage_folder
    "steps" = ["Get caris version", "data quality check","prepare change vessel config file","Create HIPS file",
  "Import to HIPS","Upload checkpoint 1 to s3","Import HIPS From Auxiliary","Upload checkpoint 2 to s3",
  "change vessel config file to calculated","Compute GPS Vertical Adjustment","change vessel config file to original",
  "Georeference HIPS Bathymetry","Upload checkpoint 3 to s3","Create Variable Resolution HIPS Grid With Cube","Upload checkpoint 5 to s3",
  "Export raster as BAG", "Export raster as LAS","Export raster as TIFF"]
  "runtask" = "\"Type\":\"Task\",\"Resource\":\"arn:aws:states:::ecs:runTask.sync\",\"ResultPath\": \"$.previous_step__result\""
  "parameters" = "\"LaunchType\":\"FARGATE\",\"Cluster\":\"${var.aws_ecs_cluster_arn}\",\"TaskDefinition\":\"${var.aws_ecs_task_definition_caris_version_arn}\",\"NetworkConfiguration\":{\"AwsvpcConfiguration\":{\"AssignPublicIp\":\"ENABLED\",\"SecurityGroups\":[\"${var.aws_ecs_task_definition_caris_sg}\"],\"Subnets\":[\"${var.aws_ecs_task_definition_caris_subnet}\"]}}"
  }
}


resource "aws_sfn_state_machine" "ausseabed-processing-pipeline-l3" {
  name     = "ausseabed-processing-pipeline-l3"
  role_arn = var.ausseabed_sm_role
  
  definition = templatefile("${path.module}/process_L3.json",local.pipeline_vars)
}

resource "aws_sfn_state_machine" "ausseabed-build-l0-sfn" {
  name     = "ausseabed-build-l0-sfn"
  role_arn = var.ausseabed_sm_role
  
  definition = templatefile("${path.module}/build_L0_coverage.json",local.pipeline_vars)
}

resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine-ga" {
  name     = "ausseabed-processing-pipeline-ga"
  role_arn = var.ausseabed_sm_role
  definition = templatefile("${path.module}/ga_processing_pipeline.json",local.pipeline_vars)
}

resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine-csiro" {
  name     = "ausseabed-processing-pipeline-csiro"
  role_arn = var.ausseabed_sm_role
  definition = templatefile("${path.module}/csiro_processing_pipeline.json", local.pipeline_vars) 
}