#-----networking/outputs.tf

output "public_subnets" {
  value = "${aws_subnet.tf_public_subnet.*.id}"
}



output "public_sg" {
  value = "${aws_security_group.tf_public_sg.id}"
}

output "aws_ecs_task_definition_caris_sg"{
  value = "${aws_security_group.tf_public_sg.id}"
}

output "subnet_ips" {
  value = "${aws_subnet.tf_public_subnet.*.cidr_block}"
}

output "aws_ecs_task_definition_caris_subnet"{
  value = "${aws_subnet.tf_public_subnet[0].id}"
}