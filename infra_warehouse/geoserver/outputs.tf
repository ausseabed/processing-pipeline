output "aws_ecs_geoserver_cluster_arn" {
  value = "${aws_ecs_cluster.geoserver_cluster.arn}"
}


output "aws_ecs_task_definition_geoserver_arn" {
  value = "${aws_ecs_task_definition.geoserver.arn}"
}


#output "aws_ecs_geoservice_arn" {
#  value = "${aws_ecs_service.geoserver_service.arn}"
#}


