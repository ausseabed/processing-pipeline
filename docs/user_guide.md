1. Create an S3 bucket
2. Upload survey data including vessel config, metadata/instruction and depth ranges files to S3. This is intented to be automated using: https://gajira.atlassian.net/browse/NGA-94 (https://gajira.atlassian.net/browse/NGA-94). However, it can still be done manually when required.
1. Trigger the appropiate pipeline from the AWS console or using AWS step function api.
1. The input of the step function is currently(December 2019):
  ```json
  {
  "s3_up_sync_command": [
    "-ip",
    "52.62.84.70",
    "-c",
    "aws s3 sync d:\\awss3bucket s3://bathymetry-survey-288871573946-csiro-matt-byod --acl public-read"
  ],
  "s3_down_sync_command": [
    "-ip",
    "52.62.84.70",
    "-c",
    "aws s3 sync s3://bathymetry-survey-288871573946-csiro-matt-byod d:\\awss3bucket"
  ],
  "resume_from": "data quality check"
}
```
1. Once the pipeline completes successfully ( a future update will add sms/email/pop up notifications) the processed data will be avilable in the same S3 bucket.
