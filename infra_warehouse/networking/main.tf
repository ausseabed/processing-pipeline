#----networking/main.tf

data "aws_availability_zones" "available" {}

resource "aws_vpc" "warehouse_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "warehouse_vpc"
  }
}

resource "aws_internet_gateway" "warehouse_internet_gateway" {
  vpc_id = aws_vpc.warehouse_vpc.id

  tags = {
    Name = "warehouse_igw"
  }
}

resource "aws_route_table" "warehouse_public_rt" {
  vpc_id = aws_vpc.warehouse_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.warehouse_internet_gateway.id
  }

  tags = {
    Name = "warehouse_public_rt"
  }
}

resource "aws_default_route_table" "warehouse_private_rt" {
  default_route_table_id = aws_vpc.warehouse_vpc.default_route_table_id

  tags = {
    Name = "warehouse_private_rt"
  }
}

resource "aws_subnet" "warehouse_public_subnet" {
  count                   = 1
  vpc_id                  = aws_vpc.warehouse_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "warehouse_public_${count.index + 1}"
  }
}

resource "aws_route_table_association" "warehouse_public_assoc" {
  count          = length(aws_subnet.warehouse_public_subnet)
  subnet_id      = aws_subnet.warehouse_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.warehouse_public_rt.id
}

resource "aws_security_group" "warehouse_public_sg" {
  name        = "warehouse_public_sg"
  description = "Used for access to the public instances"
  vpc_id      = aws_vpc.warehouse_vpc.id

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }

  # Configuration port for geoserver
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.accessip}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "geoserver_eip" {
  count = 1
  vpc   = true
}
resource "aws_lb" "geoserver_load_balancer" {
  name               = "geoserver-load-balancer"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.warehouse_public_subnet[0].id
    allocation_id = aws_eip.geoserver_eip[0].id
  }

  tags = {
    Environment = "nonproduction"
  }
}

resource "aws_lb_target_group" "geoserver_outside" {
  name     = "geoserver-outside"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.warehouse_vpc.id
  target_type = "ip"
  stickiness {
    enabled = false
    type = "lb_cookie"
  }
}


resource "aws_lb_listener" "geoserver_load_balancer_listener" {
  load_balancer_arn = aws_lb.geoserver_load_balancer.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.geoserver_outside.arn
  }
}
