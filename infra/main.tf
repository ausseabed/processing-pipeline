provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "ausseabed-processing-pipeline-tf-infra"
    key    = "terraform/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

#resource "aws_sfn_state_machine" "" {
#  name = "ausseabed-processing-pipeline"
#  role_arn = ""
#}




module "networking" {
  source       = "./networking"
  vpc_cidr     = "${var.vpc_cidr}"
  public_cidrs = "${var.public_cidrs}"
  accessip     = "${var.accessip}"
  private_cidrs = "${var.private_cidrs}"
  jumpboxip     = "${var.jumpboxip}"
}

module "compute" {
  source                      = "./compute"
  fargate_cpu                 = "${var.fargate_cpu}"
  fargate_memory              = "${var.fargate_memory}"
  caris_caller_image                   = "${var.caris_caller_image}"
  startstopec2_image                   = "${var.startstopec2_image}"
  ecs_task_execution_role_arn = "${module.ancillary.ecs_task_execution_role_arn}"
  private_subnets  = "${module.networking.private_subnets}"
  private_sg  = "${module.networking.private_sg}"
}

module "ancillary" {
  source = "./ancillary"
  ausseabed-processing-pipeline = "${aws_sfn_state_machine.ausseabed-processing-pipeline_sfn_state_machine}"
}

module "lambda_function" {
  source = "github.com/raymondbutcher/terraform-aws-lambda-builder"

  # Standard aws_lambda_function attributes.
  function_name = "getResumeFromStep"
  handler       = "getResumeFromStep.lambda_handler"
  runtime       = "python3.6"
  timeout       = 30
  role          = "${module.ancillary.getResumeFromStep_role}"
  enabled       = true

  # Enable build functionality.
  build_mode = "FILENAME"
  source_dir = "${path.module}/src/lambda/resume_from_step"
  filename   = "getResumeFromStep.py"

  # Create and use a role with CloudWatch Logs permissions.
  role_cloudwatch_logs = true
}

resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine" {
  name     = "ausseabed-processing-pipeline"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  #definition = templatefile("ausseabed-processing-pipeline_sfn_state_machine", merge("${module.compute}","${module.networking}"))
  definition = <<EOF
  {
  "StartAt": "Identify failed step",
  "States": {"Identify failed step": {
  "Type": "Task",
  "Resource": "arn:aws:states:::lambda:invoke",
    "ResultPath": "$.data.lambdaresult",
  "Parameters": {
    "FunctionName": "arn:aws:lambda:ap-southeast-2:288871573946:function:getResumeFromStep:$LATEST",
    "Payload": {
     
        "stateMachineArn": "arn:aws:states:ap-southeast-2:288871573946:stateMachine:ausseabed-processing-pipeline"
      
    }
  },
  "Next": "Start caris machine"
}  
   ,"Start caris machine": {
       "Type": "Pass",
       "Result": "Get caris version",
    "ResultPath": "$.resume_from",
   
    "Next": "Resume from step"
    
}
      ,"Resume from step": {
    "Type": "Choice",
    "Choices": [
        {
            "Variable": "$.resume_from",
            "StringEquals": "prepare landing directory",
            "Next": "prepare landing directory"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Fetch L0 data from s3",
            "Next": "Fetch L0 data from s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "data integrity check",
            "Next": "data integrity check"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Create HIPS file",
            "Next": "Create HIPS file"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Import to HIPS",
            "Next": "Import to HIPS"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload checkpoint 1 to s3",
            "Next": "Upload checkpoint 1 to s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Import HIPS From Auxiliary",
            "Next": "Import HIPS From Auxiliary"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload checkpoint 2 to s3",
            "Next": "Upload checkpoint 2 to s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Georeference HIPS Bathymetry",
            "Next": "Georeference HIPS Bathymetry"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload checkpoint 3 to s3",
            "Next": "Upload checkpoint 3 to s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Filter Processed Depths Swath",
            "Next": "Filter Processed Depths Swath"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload checkpoint 4 to s3",
            "Next": "Upload checkpoint 4 to s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Create HIPS Grid With Cube",
            "Next": "Create HIPS Grid With Cube"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload checkpoint 5 to s3",
            "Next": "Upload checkpoint 5 to s3"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Export raster as PNG",
            "Next": "Export raster as PNG"
        },
        {
            "Variable": "$.resume_from",
            "StringEquals": "Upload processed data to s3",
            "Next": "Upload processed data to s3"
        }
    ],
    "Default": "Get caris version"
}
      ,"Get caris version": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch --version ","arnab","caris_rsa_pkey_string"]}]}},"Next":"prepare landing directory","TimeoutSeconds":180      }
      ,"prepare landing directory":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"Remove-Item  d:\\awss3bucket -Recurse -Force; md d:\\awss3bucket\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Fetch L0 data from s3","TimeoutSeconds":180      }
      ,"Fetch L0 data from s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync s3://bathymetry-survey-288871573946 d:\\awss3bucket","arnab","caris_rsa_pkey_string"]}]}},"Next":"data integrity check","TimeoutSeconds":60000      }
      ,"data integrity check":{"Type":"Pass","Result":"Hello World!","Next":"Create HIPS file"      }
      ,"Create HIPS file":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"md \"D:\\awss3bucket\\GA-0364_BlueFin_MB\" ;carisbatch --run CreateHIPSFile  \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\"\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Import to HIPS","TimeoutSeconds":360      }
      ,"Import to HIPS":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\Rawdata; Get-ChildItem -File -Path  ./* -Include *.all | foreach {carisbatch --run ImportToHIPS --input-format KONGSBERG --vessel-file D:\\Bluefin\\BlueFin.hvf --convert-navigation --gps-height-device GGK  $_.fullname D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips }\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 1 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 1 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Import HIPS From Auxiliary","TimeoutSeconds":6000 }
      ,"Import HIPS From Auxiliary":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\000; carisbatch  --run ImportHIPSFromAuxiliary --input-format APP_POSMV --allow-partial  \"./*.*\" --delayed-heave 0sec --delayed-heave-rms 0sec  \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 2 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 2 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Georeference HIPS Bathymetry","TimeoutSeconds":6000     }
      ,"Georeference HIPS Bathymetry":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"carisbatch  --run GeoreferenceHIPSBathymetry  --vertical-datum-reference GPS --compute-gps-vertical-adjustment  --vertical-offset 0m --heave-source DELAYED_HEAVE --compute-tpu --tide-measured 0.1m --tide-zoning 0.1m --sv-measured 1.0m/s --sv-surface 0.2m/s --source-navigation REALTIME --source-sonar REALTIME --source-gyro REALTIME --source-pitch REALTIME --source-roll REALTIME --source-heave DELAYED --source-tide STATIC --output-components \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 3 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 3 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Filter Processed Depths Swath","TimeoutSeconds":6000     }
      ,"Filter Processed Depths Swath":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" --threshold-type STANDARD_DEVIATION --scalar 1.6 \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 4 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 4 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Create HIPS Grid With Cube","TimeoutSeconds":6000     }
      ,"Create HIPS Grid With Cube":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run CreateHIPSGridWithCube  --output-crs EPSG:32755 --extent 519410 5647240 532180  5653900 --keep-up-to-date --cube-config-file=\"D:\\Bluefin\\CUBEParams_AusSeabed_2019.xml\" --cube-config-name=AusSeabed_002m --resolution 1.0m --iho-order S44_1A \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 5 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 5 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Export raster as PNG","TimeoutSeconds":6000     }
      ,"Export raster as PNG":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \" carisbatch --run RenderRaster --input-band Depth --colour-file Rainbow.cma --enable-shading --shading 45 45 10 D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.csar ; carisbatch --run ExportRaster --output-format PNG --include-band ALL D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.png \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload processed data to s3","TimeoutSeconds":60000 }
      ,"Upload processed data to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"Next":"Stop caris machine","TimeoutSeconds":60000     }
      ,"Stop caris machine": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_startstopec2_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["OFF","i-043b8fc176ee4a5e2"]}]}},"End":true,"TimeoutSeconds":180}
      
  }
      
  }
  
  EOF

}





#carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar --threshold-type STANDARD_DEVIATION --scalar 1.6 file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips
