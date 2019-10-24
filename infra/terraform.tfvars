aws_region = "ap-southeast-2"
#project_name = "ausseabed-processing-pipeline"
vpc_cidr = "10.123.0.0/16"
public_cidrs = [
    "10.123.1.0/24"
    #,"10.123.2.0/24"
    ]
accessip = "0.0.0.0/0"


#------- compute vars---------------

fargate_cpu = 512
fargate_memory = 1024
app_image = "alpine:latest"

