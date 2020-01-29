


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


resource "aws_eip" "geoserver_eip" {
  count = 1
  vpc   = true
}
resource "aws_lb" "geoserver_load_balancer" {
  name               = "geoserver_load_balancer"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = "${var.public_subnets[0]}"
    allocation_id = "${aws_eip.geoserver_eip.id}"
  }

  tags = {
    Environment = "nonproduction"
  }
}

resource "aws_lb_target_group" "geoserver_outside" {
  name     = "geoserver_outside"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.tf_vpc.id}"
  target_type = "ip"
}


resource "aws_lb_listener" "geoserver_load_balancer_listener" {
  load_balancer_arn = "${aws_lb.geoserver_load_balancer.arn}"
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.geoserver_outside.arn}"
  }
}

resource "aws_ecs_service" "geoserver_service" {
  name            = "geoserver_service"
  cluster         = "${aws_ecs_cluster.geoserver_cluster.id}"
  task_definition = "${aws_ecs_task_definition.geoserver.arn}"
  desired_count   = 1
  launch_type = "FARGATE"
  
  load_balancer {
    target_group_arn = "${aws_lb_target_group.geoserver_outside.arn}"
    container_name   = "geoserver-task"
    container_port   = 8080
  }

  network_configuration {
    subnets="${var.public_subnets}"
    security_groups= ["${var.public_sg}"]
    assign_public_ip=true
  }

}
