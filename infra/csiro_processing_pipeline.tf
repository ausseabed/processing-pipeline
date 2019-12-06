locals {
  pipeline_vars = {
  "aws_ecs_cluster_arn" = module.compute.aws_ecs_cluster_arn 
  "aws_ecs_task_definition_startstopec2_arn" = module.compute.aws_ecs_task_definition_startstopec2_arn
  "aws_ecs_task_definition_caris_sg" = module.networking.aws_ecs_task_definition_caris_sg 
  "aws_ecs_task_definition_caris_subnet" = module.networking.aws_ecs_task_definition_caris_subnet 
  "aws_ecs_task_definition_caris-version_arn" = module.compute.aws_ecs_task_definition_caris-version_arn
  }
}
resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine-csiro" {
  name     = "${var.ausseabed-processing-pipeline-name}"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  definition = templatefile("csiro_processing_pipeline.tmpl", local.pipeline_vars) 
}