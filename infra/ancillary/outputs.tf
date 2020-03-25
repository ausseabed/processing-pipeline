# output "secret" {
#   value = "${aws_iam_access_key.circleci.encrypted_secret}"
# }

output "ausseabed-processing-pipeline_sfn_state_machine_role_arn" {
  value = aws_iam_role.ausseabed-processing-pipeline_sfn_state_machine_role.arn
}

output "caris-windows-instance-profile" {
  value = aws_iam_instance_profile.caris_windows_instance_profile.name
}


output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "getResumeFromStep_role"{
  value = aws_iam_role.getResumeFromStep-lambda-role.arn
}

output "identify_instrument_files_role"{
  value = aws_iam_role.identify_instrument_files-lambda-role.arn
}
