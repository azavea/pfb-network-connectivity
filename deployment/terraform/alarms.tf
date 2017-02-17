# set up SNS topic for monitoring
resource "aws_sns_topic" "global" {
  name = "topic${var.environment}GlobalNotifications"
}

#
# ECS Alarms
#

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_util" {
  alarm_name          = "alarm${var.environment}ECSCPUUtilization"
  alarm_description   = "Container service CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "75"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_actions = ["${aws_sns_topic.global.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_util" {
  alarm_name          = "alarm${var.environment}ECSMemoryUtilization"
  alarm_description   = "Container service memory utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    ClusterName = "${aws_ecs_cluster.container_instance.name}"
  }

  alarm_actions = ["${aws_sns_topic.global.arn}"]
}
