


resource "aws_ecs_cluster" "geoserver_cluster" {
  name = "geoserver_cluster"
}


resource "aws_ecs_task_definition" "geoserver" {
  family                   = "geoserver"
  cpu                      = "${var.server_cpu}"
  memory                   = "${var.server_memory}"
  network_mode             = "awsvpc"
  execution_role_arn       = "${var.ecs_task_execution_role_svc_arn}"
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<DEFINITION
[
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "/ecs/geoserver",
        "awslogs-region": "ap-southeast-2",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "image": "${var.geoserver_image}",
    "name": "geoserver-task",
    "networkMode": "awsvpc",
    "environment": [
      {
        "name": "INITIAL_MEMORY",
        "value": "1G"
      },
      {
        "name": "MAXIMUM_MEMORY",
        "value": "1G"
      },
      {
        "name": "GEOSERVER_ADMIN_PASSWORD",
        "value" : "c1d2-54fe-84f9-7149-f005-ffa8-cbe6-e7b4" 
      }
    ],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}


resource "aws_ecs_service" "geoserver_service" {
  name            = "geoserver_service"
  cluster         = "${aws_ecs_cluster.geoserver_cluster.id}"
  task_definition = "${aws_ecs_task_definition.geoserver.arn}"
  desired_count   = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets="${var.public_subnets}"
    security_groups= ["${var.public_sg}"]
    assign_public_ip=true
  }

}