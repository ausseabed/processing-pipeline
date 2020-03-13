1. Create an S3 bucket
2. Upload survey data including vessel config, metadata/instruction and depth ranges files to S3. This is intented to be automated using: https://gajira.atlassian.net/browse/NGA-94 (https://gajira.atlassian.net/browse/NGA-94). However, it can still be done manually when required.
1. Trigger the appropiate pipeline from the AWS console or using AWS step function api.
1. The input of the step function is currently(March 2019):
  ```json
  
{
  "s3_up_sync_command": [
    "-ip",
    "172.31.11.235",
    "-c",
    "aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946-csiro-matt-byod --acl public-read"
  ],
  "s3_down_sync_command": [
    "-ip",
    "172.31.11.235",
    "-c",
    "aws s3 sync s3://bathymetry-survey-288871573946-csiro-matt-byod d:\\awss3bucket"
  ],
  "resume_from": "Export raster as BAG"
}

{
  "s3_up_sync_command": [
    "-ip",
    "172.31.11.235",
    "-c",
    "aws s3 sync d:\\awss3bucket2 s3://bathymetry-survey-288871573946-beagle-grid0 --acl public-read"
  ],
  "s3_down_sync_command": [
    "-ip",
    "172.31.11.235",
    "-c",
    "aws s3 sync s3://bathymetry-survey-288871573946-beagle-grid0 d:\\awss3bucket2"
  ],
  "s3_src_tif": "s3://bathymetry-survey-288871573946-beagle-grid0/GA-0364_BlueFin_MB/BlueFin_2018-172_1m.tif",
  "resume_from": "Export raster as TIFF"
}
```
1. Once the pipeline completes successfully ( a future update will add sms/email/pop up notifications) the processed data will be avilable in the same S3 bucket.
