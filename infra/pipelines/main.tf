resource "aws_sfn_state_machine" "ausseabed-processing-pipeline-l3" {
  name     = "ausseabed-processing-pipeline-l3"
  role_arn = "${ausseabed_sm_role}"
  
  definition = file("${path.module}/process_L3.json")
}