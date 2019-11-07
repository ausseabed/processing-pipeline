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
}

module "compute" {
  source                      = "./compute"
  fargate_cpu                 = "${var.fargate_cpu}"
  fargate_memory              = "${var.fargate_memory}"
  app_image                   = "${var.app_image}"
  ecs_task_execution_role_arn = "${module.ancillary.ecs_task_execution_role_arn}"
}

module "ancillary" {
  source = "./ancillary"
  ausseabed-processing-pipeline = "${aws_sfn_state_machine.ausseabed-processing-pipeline_sfn_state_machine}"
}



resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine" {
  name     = "ausseabed-processing-pipeline"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  #definition = templatefile("ausseabed-processing-pipeline_sfn_state_machine", merge("${module.compute}","${module.networking}"))
  definition = <<EOF
  {
  "StartAt": "Get caris version",
  "States": {
      "Get caris version": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch --version ","arnab","caris_rsa_pkey_string"]}]}},"Next":"prepare landing directory","TimeoutSeconds":180      }
      ,"prepare landing directory":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"Remove-Item  d:\\awss3bucket -Recurse -Force; md d:\\awss3bucket\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Fetch L0 data from s3","TimeoutSeconds":180      }
      ,"Fetch L0 data from s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync s3://bathymetry-survey-288871573946 d:\\awss3bucket","arnab","caris_rsa_pkey_string"]}]}},"Next":"data integrity check","TimeoutSeconds":600      }
      ,"data integrity check":{"Type":"Pass","Result":"Hello World!","Next":"create_hips_file"      }
      ,"create_hips_file":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"md \"D:\\awss3bucket\\GA-0364_BlueFin_MB\" ;carisbatch --run CreateHIPSFile --output-crs EPSG:32755 \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\"\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Import to HIPS","TimeoutSeconds":360      }
      ,"Import to HIPS":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\Rawdata; carisbatch --run ImportToHIPS --input-format KONGSBERG --input-crs EPSG:32755 --vessel-file \"D:\\Bluefin\\BlueFin.hvf\" --convert-navigation --gps-height-device GGK  0495_20180621_105318_BlueFin.all  0505_20180621_123824_BlueFin.all  0515_20180621_140626_BlueFin.all  0525_20180621_153417_BlueFin.all  0535_20180621_170332_BlueFin.all  0496_20180621_110822_BlueFin.all  0506_20180621_124011_BlueFin.all  0516_20180621_140842_BlueFin.all  0526_20180621_153608_BlueFin.all  0536_20180621_170457_BlueFin.all 0497_20180621_111046_BlueFin.all  0507_20180621_125550_BlueFin.all  0517_20180621_142350_BlueFin.all  0527_20180621_155221_BlueFin.all  0537_20180621_172122_BlueFin.all 0498_20180621_112703_BlueFin.all  0508_20180621_125754_BlueFin.all  0518_20180621_142553_BlueFin.all  0528_20180621_155426_BlueFin.all  0538_20180621_172219_BlueFin.all 0499_20180621_112911_BlueFin.all  0509_20180621_131343_BlueFin.all  0519_20180621_144133_BlueFin.all  0529_20180621_161000_BlueFin.all  0539_20180621_173905_BlueFin.all 0500_20180621_114426_BlueFin.all  0510_20180621_131530_BlueFin.all  0520_20180621_144511_BlueFin.all  0530_20180621_161135_BlueFin.all  0540_20180621_174025_BlueFin.all 0501_20180621_120302_BlueFin.all  0511_20180621_133120_BlueFin.all  0521_20180621_145910_BlueFin.all  0531_20180621_162836_BlueFin.all  0541_20180621_175645_BlueFin.all 0502_20180621_120432_BlueFin.all  0512_20180621_133316_BlueFin.all  0522_20180621_150123_BlueFin.all  0532_20180621_162947_BlueFin.all  0542_20180621_175801_BlueFin.all 0503_20180621_122002_BlueFin.all  0513_20180621_134904_BlueFin.all  0523_20180621_151718_BlueFin.all  0533_20180621_164533_BlueFin.all  0543_20180621_180321_BlueFin.all 0504_20180621_122207_BlueFin.all  0514_20180621_135044_BlueFin.all  0524_20180621_151913_BlueFin.all  0534_20180621_164728_BlueFin.all \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\"\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Import HIPS From Auxiliary","TimeoutSeconds":360      }
      ,"Import HIPS From Auxiliary":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\000; carisbatch  --run ImportHIPSFromAuxiliary --input-format APP_POSMV --allow-partial  \"./*.*\" --input-crs EPSG:32755 --delayed-heave 0sec --delayed-heave-rms 0sec  \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Georeference HIPS Bathymetry","TimeoutSeconds":180      }
      ,"Georeference HIPS Bathymetry":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"carisbatch  --run GeoreferenceHIPSBathymetry  --vertical-datum-reference GPS --compute-gps-vertical-adjustment  --vertical-offset 0m --heave-source DELAYED_HEAVE --compute-tpu --tide-measured 0.1m --tide-zoning 0.1m --sv-measured 1.0m/s --sv-surface 0.2m/s --source-navigation REALTIME --source-sonar REALTIME --source-gyro REALTIME --source-pitch REALTIME --source-roll REALTIME --source-heave DELAYED --source-tide STATIC --output-components \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Create HIPS Grid With Cube","TimeoutSeconds":720      }
      ,"Create HIPS Grid With Cube":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run CreateHIPSGridWithCube  --output-crs EPSG:32755 --extent 519410 5647240 532180  5653900 --keep-up-to-date --cube-config-file=\"D:\\Bluefin\\CUBEParams_AusSeabed_2019.xml\" --cube-config-name=AusSeabed_002m --resolution 1.0m --iho-order S44_1A \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Filter Processed Depths","TimeoutSeconds":360      }
      ,"Filter Processed Depths":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" --threshold-type STANDARD_DEVIATION --scalar 1.6 \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload processed data to s3","TimeoutSeconds":720      }
      ,"Upload processed data to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946 --acl public-read","arnab","caris_rsa_pkey_string"]}]}},"End":true,"TimeoutSeconds":600      }
      
  }
      
  }
  
  EOF

}





#carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar --threshold-type STANDARD_DEVIATION --scalar 1.6 file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips
