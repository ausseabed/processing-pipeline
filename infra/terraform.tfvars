aws_region = "ap-southeast-2"
#project_name = "ausseabed-processing-pipeline"
vpc_cidr = "10.123.0.0/16"
public_cidrs = [
    "10.123.1.0/24"
    #,"10.123.2.0/24"
    ]
accessip = "0.0.0.0/0"
jumpboxip = "13.238.141.186/32"
private_cidrs = [
    "10.123.253.0/24"
    #,"10.123.2.0/24"
    ]

#------- compute vars---------------

fargate_cpu = 512
fargate_memory = 1024
caris_caller_image = "288871573946.dkr.ecr.ap-southeast-2.amazonaws.com/callcarisbatch:caris_caller_image-latest"
startstopec2_image = "288871573946.dkr.ecr.ap-southeast-2.amazonaws.com/callcarisbatch:startstopec2_image-latest"
