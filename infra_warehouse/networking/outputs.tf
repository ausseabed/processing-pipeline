#-----networking/outputs.tf

output "public_subnets" {
  value = "${aws_subnet.warehouse_public_subnet.*.id}"
}



output "public_sg" {
  value = "${aws_security_group.warehouse_public_sg.id}"
}


output "subnet_ips" {
  value = "${aws_subnet.warehouse_public_subnet.*.cidr_block}"
}

output "aws_ecs_lb_target_group_geoserver_arn"{
  value = "${aws_lb_target_group.geoserver_outside.arn}"
}