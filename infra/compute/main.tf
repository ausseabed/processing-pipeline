#----compute/main.tf


resource "aws_ecs_cluster" "main" {
  name = "tf-ecs-cluster"
}

resource "aws_ecs_task_definition" "caris-version" {
  family                   = "caris-version"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${var.ecs_task_execution_role_arn}"

  container_definitions = <<DEFINITION
[
  {
    "command": ["52.62.84.70",
        "C:\\Program Files\\CARIS\\HIPS and SIPS\\11.2\\bin\\carisbatch\\ --version",
        "arnab"],
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}


resource "aws_ecs_task_definition" "create-hips-file" {
  family                   = "create-hips-file"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${var.ecs_task_execution_role_arn}"

  container_definitions = <<DEFINITION
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${var.app_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}

