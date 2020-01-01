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
1. The step function will start the appropiate caris instance. Either
  1. the caris instance in the same account
  1. Or using the "-ip" argument as passed to the docker comamnd.
1. Next the step function will identify which step to resume from as per:
  1. Either the value of "resume_from_step"  input parameter
  1. or the failed step during the last execution
1 

## TODOs:
### Test cases:
1. There arn't any test cases at the moment because there is very little custom code. Most of the system is built using integration of various off the shelf components. However, this calls for at least some form of integration testing. A simple but very effective test will be to run the pipeline on a known dataset and comparing the output to the known output. This test will be run using the CI pipeline while deploying a new version of the data pipleine.
...more to come
   
## Design descisions:
A spike activity was undertaken to compare and contrast various workflow like software before picking step functions. The activity is summarised in the following table: https://drive.google.com/open?id=1r1VmJI2KE0j7MUZG7a_x6OE2fN5NfIRoRZouRweKtxw

Step functions is used as the workflow engine which orchestrates various steps int he processing pipeline. The steps are manifested either as a docker or lambda executions

...more to come

## Design philosopy:

[Serverless](https://serverless.com/learn/manifesto/) first. Any need to run and manage a server needs to be justified. Valid reasons include: software (like Caris) which is not available as a service or can not be run on serverless platforms:

