##### _This document is meant to be a read in conjunction with the code in this repository. It is a living document and the contents in this document can get out of sync with what "actually" happens in the code. If ever such a schism is spotted either create a PR, lodge an issue in github or [jira](https://gajira.atlassian.net/jira/software/projects/NGA/boards/520)._

## Design philosopy:

[Serverless](https://serverless.com/learn/manifesto/) first. Any need to run and manage a server needs to be justified. Valid reasons include: software (like Caris) which is not available as a service or can not be run on serverless platforms:

## Design descisions:
A spike activity was undertaken to compare and contrast various workflow like software before picking step functions. The activity is summarised in the following table: https://drive.google.com/open?id=1r1VmJI2KE0j7MUZG7a_x6OE2fN5NfIRoRZouRweKtxw

Step functions is used as the workflow engine which orchestrates various steps in the processing pipeline. The steps are manifested either as a docker or lambda executions

The step function is stored in a code repository as a json document. There were various ways to write the step function each having their own tradeoffs. We decided to make the step function itself more readable and informative. This means raw caris commands are visible directly in the step function json document instead of them being in the docker image. The tradeoff was that this made the json dcument more verbose. However, the verbosity can be managed by using templates to reduce repetations and/or un-informative verbosity. 

...more to come

## Skills and tools used
* AWS cloud services
  * AWS Step function
  * AWS Lambda
  * AWS Cloudwatch
  * AWS Secrets Manager
  * AWS IAM
  * AWS Fargate
  * AWS S3
  * AWS EC2
  * AWS VPC networking
  * AWS ECR
* Python
* Powershell
* Docker
* Kubernetes / Fargate

## How it works at a high level:
Terraform is used to create the infrastructure stack. Every component is treated as ephemeral except the EC2 instance hosting Caris software. [Caris hips-and-sips](https://www.teledynecaris.com/en/products/hips-and-sips/) is a licensed software. As of today ( Jan 2020) a trial license has been activate on the static EC2 server (ip:52.62.84.70) which has a version of Caris hips-and-sips installed manually. Creation of the EC2 with Caris has been codified as well using packer in a different [repo](https://github.com/GeoscienceAustralia/ausseabed-caris-ami).
The processing pipeline is triggered either manually from the AWS console, through AWS API or automatically on file upload to S3 bucket. The processing pipeline takes care of orchestrating the various tasks involved in processing a survey data. Once complete the processed data is uploaded to S3 ( in reality sync to s3 is done after every major step to make the system more fault tolerant).
Each step in the step function is either a lambda execution or a docker container execution in fargate.


## TODOs:
### Test cases:
1. There arn't any test cases at the moment because there is very little custom code. Most of the system is built using integration of various off the shelf components. However, this calls for at least some form of integration testing. A simple but very effective test will be to run the pipeline on a known dataset and comparing the output to the known output. This test will be run using the CI pipeline while deploying a new version of the data pipleine.

...more to come
   
