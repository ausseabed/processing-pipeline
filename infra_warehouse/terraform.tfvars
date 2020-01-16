aws_region = "ap-southeast-2"
project_name = "ausseabed-processing-pipeline"
vpc_cidr = "173.31.0.0/16"
public_cidrs = [
    "173.31.0.0/16"
    ]
accessip = "0.0.0.0/0"

# geoserver/mapserver vars
server_cpu = 512
server_memory = 1024
#------- compute vars---------------

#fargate_cpu = 512
#fargate_memory = 1024
geoserver_image = "288871573946.dkr.ecr.ap-southeast-2.amazonaws.com/callcarisbatch:ausseabed-geoserver-2.16.1"

geoserver_initial_memory="1G"
geoserver_maximum_memory="1G"
geoserver_admin_password="c1d2-54fe-84f9-7149-f005-ffa8-cbe6-e7b4"