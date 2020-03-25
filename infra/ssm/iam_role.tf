resource "aws_iam_role" "maintenance_role" {
  name = "${var.stack_name}-maintenance-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
           "ec2.amazonaws.com",
           "ssm.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cloud-watch-agent-policy" {
  name        = "CloudWatchAgentServerPolicy"
  path        = "/"
  description = "Policy to be able to work with the Cloud Watch agent."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
    "Sid": "CloudWatchAgentServerPolicy",
    "Effect": "Allow",
    "Action": [
      "logs:CreateLogStream",
      "cloudwatch:PutMetricData",
      "ec2:DescribeTags",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "ssm:GetParameter"
    ],
    "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
    role       = "${aws_iam_role.maintenance_role.name}"
    # Service Role to be used for EC2 Maintenance Window
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

resource "aws_iam_role_policy_attachment" "cloud-watch-agent-access" {
  role       = "${aws_iam_role.maintenance_role.name}"
  policy_arn = "${aws_iam_policy.cloud-watch-agent-policy.arn}"
}
