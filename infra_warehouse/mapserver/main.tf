
resource "aws_ecs_cluster" "mapserver_cluster" {
  name = "mapserver_cluster"
}


resource "aws_ecs_task_definition" "mapserver" {
  family                   = "mapserver"
  cpu                      = var.server_cpu
  memory                   = var.server_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_task_execution_role_svc_arn
  container_definitions = <<DEFINITION
[
  {
    "logConfiguration": {
      "logDriver": "awslogs",
      "secretOptions": null,
      "options": {
        "awslogs-group": "/ecs/mapserver",
        "awslogs-region": "ap-southeast-2",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "image": "camptocamp/mapserver",
    "name": "mapserver-task",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      },
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}


resource "aws_ecs_service" "mapserver_service" {
  name            = "mapserver_service"
  cluster         = aws_ecs_cluster.mapserver_cluster.id
  task_definition = aws_ecs_task_definition.mapserver.arn
  desired_count   = 1
  launch_type = "FARGATE"
  #iam_role        = "${aws_iam_role.foo.arn}"
  #depends_on      = ["aws_iam_role_policy.foo"]

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }
  network_configuration {
    subnets=var.public_subnets
    security_groups= ["${var.public_sg}"]
    assign_public_ip=true
  }


  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}
