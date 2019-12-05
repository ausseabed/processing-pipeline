
output "aws_ecs_mapserver_cluster_arn" {
  value = "${aws_ecs_cluster.mapserver_cluster.arn}"
}


output "aws_ecs_task_definition_mapserver_arn" {
  value = "${aws_ecs_task_definition.mapserver.arn}"
}


#output "aws_ecs_mapservice_arn" {
#  value = "${aws_ecs_service.mapserver_service.arn}"
#}

