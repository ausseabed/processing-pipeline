locals {
  pipeline_vars = {
  "steps" = ["Get caris version", "data integrity check","prepare change vessel config file","Create HIPS file","Import to HIPS","Upload checkpoint 1 to s3","Import HIPS From Auxiliary","Upload checkpoint 2 to s3","change vessel config file to calculated","Compute GPS Vertical Adjustment","change vessel config file to original","Georeference HIPS Bathymetry","Upload checkpoint 3 to s3","Filter Processed Depths Swath","Upload checkpoint 4 to s3","Create HIPS Grid With Cube","Upload checkpoint 5 to s3","Export raster as PNG"]
  "aws_ecs_cluster_arn" = module.compute.aws_ecs_cluster_arn 
  "aws_ecs_task_definition_startstopec2_arn" = module.compute.aws_ecs_task_definition_startstopec2_arn
  "aws_ecs_task_definition_caris_sg" = module.networking.aws_ecs_task_definition_caris_sg 
  "aws_ecs_task_definition_caris_subnet" = module.networking.aws_ecs_task_definition_caris_subnet 
  "aws_ecs_task_definition_caris-version_arn" = module.compute.aws_ecs_task_definition_caris-version_arn
  "local_storage_folder"= var.local_storage_folder
  }
}
resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine-csiro" {
  name     = "${var.ausseabed-processing-pipeline-name}"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  definition = templatefile("csiro_processing_pipeline.tmpl", local.pipeline_vars) 
}