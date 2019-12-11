resource "aws_sfn_state_machine" "ausseabed-processing-pipeline_sfn_state_machine-ga" {
  name     = "ausseabed-processing-pipeline-ga"
  role_arn = "${module.ancillary.ausseabed-processing-pipeline_sfn_state_machine_role_arn}"
  
  definition = <<EOF
  {
  "StartAt": "Start caris machine",
  "States": {
  "Start caris machine": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_startstopec2_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["ON","caris"]}]}},"Next":"Identify failed step","TimeoutSeconds":180 }
  ,"Identify failed step": {
  "Type": "Task",
  "Resource": "arn:aws:states:::lambda:invoke",
    "ResultPath": "$.data.lambdaresult",
  "Parameters": {
    "FunctionName": "arn:aws:lambda:ap-southeast-2:288871573946:function:getResumeFromStep:$LATEST",
    "Payload": {
     
        "stateMachineArn": "arn:aws:states:ap-southeast-2:288871573946:stateMachine:ausseabed-processing-pipeline-ga"
      
    }
  },
  "Next": "Resume from step"
}  
   
      ,"Resume from step": {
    "Type": "Choice",
    "Choices": [
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "prepare landing directory",
            "Next": "prepare landing directory"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Fetch L0 data from s3",
            "Next": "Fetch L0 data from s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "data integrity check",
            "Next": "data integrity check"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Create HIPS file",
            "Next": "Create HIPS file"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Import to HIPS",
            "Next": "Import to HIPS"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload checkpoint 1 to s3",
            "Next": "Upload checkpoint 1 to s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Import HIPS From Auxiliary",
            "Next": "Import HIPS From Auxiliary"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload checkpoint 2 to s3",
            "Next": "Upload checkpoint 2 to s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Georeference HIPS Bathymetry",
            "Next": "Georeference HIPS Bathymetry"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload checkpoint 3 to s3",
            "Next": "Upload checkpoint 3 to s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Filter Processed Depths Swath",
            "Next": "Filter Processed Depths Swath"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload checkpoint 4 to s3",
            "Next": "Upload checkpoint 4 to s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Create HIPS Grid With Cube",
            "Next": "Create HIPS Grid With Cube"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload checkpoint 5 to s3",
            "Next": "Upload checkpoint 5 to s3"
        },
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Export raster as PNG",
            "Next": "Export raster as PNG"
        },
        {"Or": [
            {
                "Variable": "$.data.lambdaresult.Payload.body.state",
                "StringEquals": "Export raster as TIFF"
            },
            {
                "Variable": "$.resume_from",
                "StringEquals": "Export raster as TIFF"
            }
        ],
            "Next": "Export raster as TIFF"
        },
          
        {"Or": [
            {
                "Variable": "$.data.lambdaresult.Payload.body.state",
                "StringEquals": "Export raster as BAG"
            },
            {
                "Variable": "$.resume_from",
                "StringEquals": "Export raster as BAG"
            }
        ],
            "Next": "Export raster as BAG"
        },      
        {"Or": [
            {
                "Variable": "$.data.lambdaresult.Payload.body.state",
                "StringEquals": "Export raster as LAS"
            },
            {
                "Variable": "$.resume_from",
                "StringEquals": "Export raster as LAS"
            }
        ],
            "Next": "Export raster as LAS"
        },       

        
        {
            "Variable": "$.data.lambdaresult.Payload.body.state",
            "StringEquals": "Upload processed data to s3",
            "Next": "Upload processed data to s3"
        }
    ],
    "Default": "Get caris version"
}
      ,"Get caris version": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch --version ","arnab","caris_rsa_pkey_string"]}]}},"Next":"prepare landing directory","TimeoutSeconds":180      }
      ,"prepare landing directory":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"Remove-Item  d:\\awss3bucket -Recurse -Force; md d:\\awss3bucket\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Fetch L0 data from s3","TimeoutSeconds":180      }
      ,"Fetch L0 data from s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_down_sync_command"}]}},"Next":"data integrity check","TimeoutSeconds":60000      }
      ,"data integrity check":{"Type":"Pass","Result":"Hello World!","ResultPath": "$.previous_step__result","Next":"Create HIPS file"      }
      ,"Create HIPS file":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"md \"D:\\awss3bucket\\GA-0364_BlueFin_MB\" ;carisbatch --run CreateHIPSFile  \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\"\"","arnab","caris_rsa_pkey_string"]}]}},"Next":"Import to HIPS","TimeoutSeconds":360      }
      ,"Import to HIPS":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\Rawdata; Get-ChildItem -File -Path  ./* -Include *.all | foreach {carisbatch --run ImportToHIPS --input-format KONGSBERG --vessel-file D:\\awss3bucket\\BlueFin.hvf --convert-navigation --gps-height-device GGK  $_.fullname D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips }\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 1 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 1 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Import HIPS From Auxiliary","TimeoutSeconds":6000 }
      ,"Import HIPS From Auxiliary":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"cd D:\\awss3bucket\\000; carisbatch  --run ImportHIPSFromAuxiliary --input-format APP_POSMV --allow-partial  \"./*.*\" --delayed-heave 0sec --delayed-heave-rms 0sec  \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 2 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 2 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Georeference HIPS Bathymetry","TimeoutSeconds":6000     }
      ,"Georeference HIPS Bathymetry":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \"carisbatch  --run GeoreferenceHIPSBathymetry  --vertical-datum-reference GPS --compute-gps-vertical-adjustment  --vertical-offset 0m --heave-source DELAYED_HEAVE --compute-tpu --tide-measured 0.1m --tide-zoning 0.1m --sv-measured 1.0m/s --sv-surface 0.2m/s --source-navigation REALTIME --source-sonar REALTIME --source-gyro REALTIME --source-pitch REALTIME --source-roll REALTIME --source-heave DELAYED --source-tide STATIC --output-components \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 3 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 3 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Filter Processed Depths Swath","TimeoutSeconds":6000     }
      ,"Filter Processed Depths Swath":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run FilterProcessedDepths   --filter-type SURFACE --surface \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" --threshold-type STANDARD_DEVIATION --scalar 1.6 \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 4 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 4 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Create HIPS Grid With Cube","TimeoutSeconds":6000     }
      ,"Create HIPS Grid With Cube":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell carisbatch  --run CreateHIPSGridWithCube  --output-crs EPSG:32755 --extent 484650 5630110 541390 5658320 --keep-up-to-date --cube-config-file=\"D:\\Bluefin\\CUBEParams_AusSeabed_2019.xml\" --cube-config-name=AusSeabed_002m --resolution 1.0m --iho-order S44_1A \"file:///D:\\awss3bucket\\GA-0364_BlueFin_MB\\GA-0364_BlueFin_MB.hips\" \"D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar\" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload checkpoint 5 to s3","TimeoutSeconds":60000     }
      ,"Upload checkpoint 5 to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Export raster as PNG","TimeoutSeconds":6000     }
      ,"Export raster as PNG":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \" carisbatch --run RenderRaster --input-band Depth --colour-file Rainbow.cma --enable-shading --shading 45 45 10 D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.csar ; carisbatch --run ExportRaster --output-format PNG --include-band ALL D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m_coloured.png \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Export raster as TIFF","TimeoutSeconds":60000 }
      ,"Export raster as TIFF":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \" carisbatch --run ExportRaster --output-format GEOTIFF --include-band ALL D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.tif \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Export raster as BAG","TimeoutSeconds":60000 }
      ,"Export raster as BAG":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \" carisbatch --run ExportRaster --output-format BAG --include-band Depth --uncertainty Uncertainty --uncertainty-type PRODUCT_UNCERT --abstract undefined --status UNDER_DEV --vertical-datum MLLW --party-name undefined --party-position undefined --party-organization undefined --party-role POINT_OF_CONTACT --legal-constraints OTHER_RESTRICTIONS --other-constraints NA --security-constraints UNCLASSIFIED --notes NA --compression-level 1 D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.bag \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Export raster as LAS","TimeoutSeconds":60000 }
      ,"Export raster as LAS":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["52.62.84.70","powershell \" carisbatch --run ExportPoints --output-format LAS --include-band ALL --las-version 1.4 D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.csar D:\\awss3bucket\\GA-0364_BlueFin_MB\\BlueFin_2018-172_1m.las \" ","arnab","caris_rsa_pkey_string"]}]}},"Next":"Upload processed data to s3","TimeoutSeconds":60000 }
      ,"Upload processed data to s3":{"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_caris-version_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command.$":"$.s3_up_sync_command"}]}},"Next":"Stop caris machine","TimeoutSeconds":60000     }
      ,"Stop caris machine": {"Type":"Task","Resource":"arn:aws:states:::ecs:runTask.sync","ResultPath": "$.previous_step__result","Parameters":{"LaunchType":"FARGATE","Cluster":"${module.compute.aws_ecs_cluster_arn}","TaskDefinition":"${module.compute.aws_ecs_task_definition_startstopec2_arn}","NetworkConfiguration":{"AwsvpcConfiguration":{"AssignPublicIp":"ENABLED","SecurityGroups":["${module.networking.aws_ecs_task_definition_caris_sg}"],"Subnets":["${module.networking.aws_ecs_task_definition_caris_subnet}"]}},"Overrides":{"ContainerOverrides":[{"Name":"app","Command":["OFF","caris"]}]}},"End":true,"TimeoutSeconds":180}
      
  }
      
  }
  
  EOF

}