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
  task_role_arn            = "${var.ecs_task_execution_role_arn}"

  container_definitions = <<DEFINITION
[
  {
    "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/caris-version",
          "awslogs-region": "ap-southeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
    "command": ["52.62.84.70",
        "\"C:\\Program Files\\CARIS\\HIPS and SIPS\\11.2\\bin\\carisbatch\" --version",
        "arnab",
        "caris_rsa_pkey_string"],
    "secrets": [
        {
          "valueFrom": "arn:aws:secretsmanager:ap-southeast-2:288871573946:secret:caris_batch_secret-OMZKQN",
          "name": "caris_rsa_pkey_string"
        }
      ],
    "cpu": ${var.fargate_cpu},
    "image": "${var.caris_caller_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}


resource "aws_ecs_task_definition" "startstopec2" {
  family                   = "startstopec2"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  execution_role_arn       = "${var.ecs_task_execution_role_arn}"
  task_role_arn            = "${var.ecs_task_execution_role_arn}"

  container_definitions = <<DEFINITION
[
  { "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/startstopec2",
          "awslogs-region": "ap-southeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
    "cpu": ${var.fargate_cpu},
    "image": "${var.startstopec2_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "gdal" {
  family                   = "gdal"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = <<DEFINITION
[
  { "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/startstopec2",
          "awslogs-region": "ap-southeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
    "cpu": ${var.fargate_cpu},
    "image": "${var.gdal_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "mbsystem" {
  family                   = "mbsystem"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = <<DEFINITION
[
  { "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/startstopec2",
          "awslogs-region": "ap-southeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
    "cpu": ${var.fargate_cpu},
    "image": "${var.mbsystem_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}

resource "aws_ecs_task_definition" "pdal" {
  family                   = "pdal"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = <<DEFINITION
[
  { "logConfiguration": {
        "logDriver": "awslogs",
        "secretOptions": null,
        "options": {
          "awslogs-group": "/ecs/startstopec2",
          "awslogs-region": "ap-southeast-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
    "cpu": ${var.fargate_cpu},
    "image": "${var.pdal_image}",
    "memory": ${var.fargate_memory},
    "name": "app",
    "networkMode": "awsvpc",
    "portMappings": []
  }
]
DEFINITION
}


data "aws_caller_identity" "current" {}



#data "aws_ami" "caris" {
#  most_recent = true
#  owners = ["self"] # Canonical
#}


resource "aws_instance" "caris-instance" {
  ami           = "ami-0d7d61afb25447cf2"
  instance_type = "t2.micro"
  subnet_id = "${var.public_subnets[0]}"
  vpc_security_group_ids = ["${var.public_sg}"]
  tags = {
    Name = "caris"
  }
}

resource "aws_eip" "caris-instance" {
  instance = "${aws_instance.caris-instance.id}"
  vpc      = true
}