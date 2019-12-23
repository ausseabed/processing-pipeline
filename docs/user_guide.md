1. Create an S3 bucket
2. Upload survey data including vessel config, metadata/instruction and depth ranges files to S3. This is intented to be automated using: https://gajira.atlassian.net/browse/NGA-94 (https://gajira.atlassian.net/browse/NGA-94). However, it can still be done manually when required.
1. Trigger the appropiate pipeline from the AWS console or using AWS step function api.
1. The step function will start the appropiate caris instance. Either
  1. the caris instance in the same account
  1. Or using the "-ip" argument as passed to the docker comamnd.
1. Next the step function will identify which step to resume from as per:
  1. Either the value of "resume_from_step"  input parameter
  1. or the failed step during the last execution
1 
   
