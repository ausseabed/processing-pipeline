


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
        "name": "GEOSERVER_URL",
        "value": "http://localhost:8080/geoserver"
      },
      {
        "name": "LIST_PATH",
        "value": "https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json"
      },
      {
        "name": "INITIAL_MEMORY",
        "value": "${var.geoserver_initial_memory}"
      },
      {
        "name": "MAXIMUM_MEMORY",
        "value": "${var.geoserver_maximum_memory}"
      },
      {
        "name": "GEOSERVER_ADMIN_PASSWORD",
        "value" : "${var.geoserver_admin_password}" 
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


# GEOSERVER_URL = "http://ec2-54-153-228-148.ap-southeast-2.compute.amazonaws.com/geoserver"
# GEOSERVER_ADMIN_PASSWORD = 
# LIST_PATH = "https://bathymetry-survey-288871573946.s3-ap-southeast-2.amazonaws.com/registered_files.json