


resource "aws_ecs_cluster" "geoserver_cluster" {
  name = "geoserver_cluster"
}


resource "aws_ecs_task_definition" "geoserver" {
  family                   = "geoserver"
  cpu                      = var.server_cpu
  memory                   = var.server_memory
  network_mode             = "awsvpc"
  execution_role_arn       = var.ecs_task_execution_role_svc_arn
  task_role_arn       = var.ecs_task_execution_role_svc_arn
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
        "value": "https://ausseabed-public-bathymetry-nonprod.s3-ap-southeast-2.amazonaws.com/registered_files.json"
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
      },
      {
        "name": "COMMUNITY_EXTENSIONS",
        "value" : "gwc-s3-plugin" 
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
  cluster         = aws_ecs_cluster.geoserver_cluster.id
  task_definition = aws_ecs_task_definition.geoserver.arn
  desired_count   = 1
  launch_type = "FARGATE"
  
  load_balancer {
    target_group_arn = var.aws_ecs_lb_target_group_geoserver_arn
    container_name   = "geoserver-task"
    container_port   = 8080
  }

  network_configuration {
    subnets=var.public_subnets
    security_groups= ["${var.public_sg}"]
    assign_public_ip=true
  }

}
