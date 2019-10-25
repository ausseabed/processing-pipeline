output "aws_ecs_cluster_arn" {
  value = "${aws_ecs_cluster.main.arn}"
}


output "aws_ecs_task_definition_caris-version_arn" {
  value = "${aws_ecs_task_definition.caris-version.arn}"
}
