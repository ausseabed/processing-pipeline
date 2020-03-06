#----ancillary/main.tf

resource "aws_ecr_repository" "callcarisbatch" {
  name = "callcarisbatch"
  image_tag_mutability = "MUTABLE"
  tags = {
       Name = "tf_ecr"
  }
} 


resource "aws_iam_user" "circleci" {
  name = "circleci"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

# resource "aws_iam_access_key" "circleci" {
#   user = "${aws_iam_user.circleci.name}"
# }

resource "aws_iam_user_policy" "circleci_ecr_all" {
  name = "test"
  user = aws_iam_user.circleci.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}





resource "aws_iam_role" "ausseabed-processing-pipeline_sfn_state_machine_role" {
  name = "ausseabed-processing-pipeline_sfn_state_machine_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "ausseabed-processing-pipeline_sfn_state_machine_policy" {
  name = "ausseabed-processing-pipeline_sfn_state_machine_policy"
  role = aws_iam_role.ausseabed-processing-pipeline_sfn_state_machine_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RunTask"
            ],
            "Resource": [
                "arn:aws:ecs:ap-southeast-2:288871573946:task-definition/*"
            ]
        },
         {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:ap-southeast-2:288871573946:function:getResumeFromStep:$LATEST"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
                "arn:aws:lambda:ap-southeast-2:288871573946:function:identify_instrument_files:$LATEST"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecs:StopTask",
                "ecs:DescribeTasks"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "events:PutTargets",
                "events:PutRule",
                "events:DescribeRule"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        }
    ]
}
EOF
}



#------------- execution role arn -------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "ecs_task_execution_policy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GAS3ReadWrite",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObj*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },{
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "arn:aws:secretsmanager:ap-southeast-2:288871573946:secret:caris_batch_secret-OMZKQN"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "secretsmanager:GetRandomPassword",
            "Resource": "*"
        },{
            "Sid": "startstopec2",
            "Effect": "Allow",
            "Action": [
                "ec2:StartInstances",
                "ec2:StopInstances"
            ],
            "Resource": "arn:aws:ec2:ap-southeast-2:288871573946:instance/*"
        },{
            "Sid": "startstopec2FindInstance",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_cloudwatch_log_group" "caris-version" {
  name = "/ecs/caris-version"

  tags = {
    Environment = "poc"
    Application = "caris"
  }
}

resource "aws_cloudwatch_log_group" "startstopec2" {
  name = "/ecs/startstopec2"

  tags = {
    Environment = "poc"
    Application = "caris"
  }
}

resource "aws_cloudwatch_log_group" "step-functions" {
  name = "/ecs/steps"

  tags = {
    Environment = "poc"
    Application = "caris"
  }
}

data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "bathymetry-survey" {
  bucket = "bathymetry-survey-${data.aws_caller_identity.current.account_id}"
}


resource "aws_cloudtrail" "raw-data-available-in-bathymetry-survey-trail" {
  name                          = "raw-data-available-in-bathymetry-survey-trail"
  s3_bucket_name                = aws_s3_bucket.bucket-for-cloudtrail.id
  s3_key_prefix                 = "prefix"

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      # Make sure to append a trailing '/' to your ARN if you want
      # to monitor all objects in a bucket.
      values = ["${aws_s3_bucket.bathymetry-survey.arn}/.done"]
    }
  }
}


resource "aws_s3_bucket" "bucket-for-cloudtrail" {
  bucket        = "bucket-for-cloudtrail-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::bucket-for-cloudtrail-${data.aws_caller_identity.current.account_id}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::bucket-for-cloudtrail-${data.aws_caller_identity.current.account_id}/prefix/AWSLogs/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}


resource "aws_cloudwatch_event_rule" "trigger-processing-pipeline" {
  name        = "trigger-processing-pipeline"
  description = "trigger-processing-pipeline on s3 event"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "bathymetry-survey-288871573946"
      ]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "asf" {
  rule      = aws_cloudwatch_event_rule.trigger-processing-pipeline.name
  target_id = "trigger-step-function"
  arn       = var.ausseabed-processing-pipeline.id
  role_arn  = aws_iam_role.asf_events.arn
}


resource "aws_iam_role" "asf_events" {
  name = "asf_events"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

// assigning premission to the role
resource "aws_iam_role_policy" "asf_events_run_task_with_any_role" {
  name = "asf_events_run_task_with_any_role"
  role = aws_iam_role.asf_events.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": [
                "arn:aws:states:ap-southeast-2:${data.aws_caller_identity.current.account_id}:stateMachine:ausseabed-processing-pipeline"
            ]
        }
    ]
}
DOC
}


resource "aws_iam_role" "ec2_instance_s3" {
  name = "ec2_instance_s3"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "s3_read_write" {
  name = "s3_read_write"
  role = aws_iam_role.ec2_instance_s3.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "GAS3ReadWrite",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:PutObj*",
                "s3:DeleteObj"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
DOC
}

resource "aws_iam_instance_profile" "ec2_instance_s3_profile" {
  name = "ec2_instance_s3_profile"
  role = aws_iam_role.ec2_instance_s3.name
}



resource "aws_iam_role" "identify_instrument_files-lambda-role" {
  name = "identify_instrument_files-lambda-role"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}


resource "aws_iam_role_policy" "identify_instrument_files-lambda-role-policy" {
  name = "identify_instrument_files-lambda-role-policy"
  role = aws_iam_role.identify_instrument_files-lambda-role.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "forCloudtrail",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:ap-southeast-2:288871573946:log-group:/aws/lambda/identify_instrument_files:*"
        },
        {
            "Sid": "forStepFunctions",
            "Effect": "Allow",
            "Action": [
                "states:ListStateMachines",
                "states:ListActivities",
                "states:ListExecutions",
                "states:GetExecutionHistory",
                "states:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "forCloudwatch",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-southeast-2:288871573946:*"
        }
    ]
}
DOC
}

resource "aws_iam_role" "getResumeFromStep-lambda-role" {
  name = "getResumeFromStep-lambda-role"

  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "getResumeFromStep-lambda-role-policy" {
  name = "getResumeFromStep-lambda-role-policy"
  role = aws_iam_role.getResumeFromStep-lambda-role.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "forCloudtrail",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:ap-southeast-2:288871573946:log-group:/aws/lambda/getResumeFromStep:*"
        },
        {
            "Sid": "forStepFunctions",
            "Effect": "Allow",
            "Action": [
                "states:ListStateMachines",
                "states:ListActivities",
                "states:ListExecutions",
                "states:GetExecutionHistory",
                "states:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "forCloudwatch",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-southeast-2:288871573946:*"
        }
    ]
}
DOC
}