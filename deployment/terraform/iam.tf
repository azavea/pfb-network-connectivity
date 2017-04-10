#
# IAM Resources
#
data "aws_iam_policy_document" "container_instance_ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "container_instance_ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "container_instance_ses_send_email" {
  statement {
    effect = "Allow"

    resources = ["*"]
    actions   = ["ses:SendRawEmail"]
  }
}

data "aws_iam_policy_document" "batch_manage_jobs" {
  statement {
    effect = "Allow"

    resources = ["*"]

    actions = [
      "batch:CancelJob",
      "batch:DescribeJobDefinitions",
      "batch:DescribeJobQueues",
      "batch:DescribeJobs",
      "batch:ListJobs",
      "batch:SubmitJob",
      "batch:TerminateJob",
    ]
  }
}

#
# Custom policies
#
resource "aws_iam_policy" "batch_manage_jobs" {
  name   = "BatchManageJobs"
  policy = "${data.aws_iam_policy_document.batch_manage_jobs.json}"
}

#
# ECS roles
#
resource "aws_iam_role" "container_instance_ecs" {
  name               = "ecs${var.environment}InstanceRole"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_ecs_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2_policy_pfb_app_ecs_role" {
  role       = "${aws_iam_role.container_instance_ecs.name}"
  policy_arn = "${var.aws_ecs_for_ec2_service_role_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = "${aws_iam_role.container_instance_ecs.name}"
  policy_arn = "${var.aws_ecs_service_role_policy_arn}"
}

resource "aws_iam_role_policy" "ses_send_email" {
  name   = "SESSendEmail"
  role   = "${aws_iam_role.container_instance_ecs.id}"
  policy = "${data.aws_iam_policy_document.container_instance_ses_send_email.json}"
}

resource "aws_iam_role_policy_attachment" "sqs_read_write" {
  role       = "${aws_iam_role.container_instance_ecs.name}"
  policy_arn = "${var.aws_sqs_read_write_policy_arn}"
}

#
# EC2 roles
#
resource "aws_iam_role" "container_instance_ec2" {
  name               = "${var.environment}ContainerInstanceProfile"
  assume_role_policy = "${data.aws_iam_policy_document.container_instance_ec2_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "batch_manage_jobs_policy_container_instance_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "${aws_iam_policy.batch_manage_jobs.arn}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy_container_instance_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "${var.aws_cloudwatch_logs_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "${var.aws_s3_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2_policy_container_instance_role" {
  role       = "${aws_iam_role.container_instance_ec2.name}"
  policy_arn = "${var.aws_ecs_for_ec2_service_role_policy_arn}"
}

resource "aws_iam_instance_profile" "container_instance" {
  name  = "${aws_iam_role.container_instance_ec2.name}"
  roles = ["${aws_iam_role.container_instance_ec2.name}"]
}
