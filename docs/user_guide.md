1. Create an S3 bucket
2. Upload survey data including vessel config, metadata/instruction and depth ranges files to S3. This is intented to be automated using: https://gajira.atlassian.net/browse/NGA-94 (https://gajira.atlassian.net/browse/NGA-94). However, it can still be done manually when required.
1. Trigger the appropiate pipeline from the AWS console or using AWS step function api.
1. The input of the step function is described in https://github.com/ausseabed/ausseabed-aws-tf-processing-pipeline repo
