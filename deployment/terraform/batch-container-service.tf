#
# Security group resources
#
resource "aws_security_group" "batch_container_instance" {
  vpc_id = "${module.vpc.id}"

  tags {
    Name        = "sgBatchContainerInstance"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

#
# Autoscaling Resources
#
data "template_file" "batch_container_instance_cloud_config" {
  template = "${file("cloud-config/ecs-batch-user-data.yml")}"

  vars {
    ecs_cluster_name = "${var.batch_ecs_cluster_name}"
    environment      = "${var.environment}"
  }
}

resource "aws_launch_configuration" "batch_container_instance" {
  lifecycle {
    create_before_destroy = true
  }

  ebs_optimized = true
  iam_instance_profile = "${aws_iam_instance_profile.container_instance.name}"
  image_id             = "${var.ecs_instance_ami_id}"
  instance_type        = "${var.batch_container_instance_type}"
  key_name             = "${var.aws_key_name}"
  security_groups      = ["${aws_security_group.container_instance.id}"]

  user_data = "${data.template_file.batch_container_instance_cloud_config.rendered}"
}

resource "aws_autoscaling_group" "batch_container_instance" {
  name = "asg${var.environment}BatchContainerInstance"

  launch_configuration      = "${aws_launch_configuration.batch_container_instance.name}"
  health_check_type         = "EC2"
  desired_capacity          = "${var.batch_container_instance_asg_desired_capacity}"
  min_size                  = "${var.batch_container_instance_asg_min_size}"
  max_size                  = "${var.batch_container_instance_asg_max_size}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  vpc_zone_identifier = ["${module.vpc.private_subnet_ids}"]

  tag {
    key                 = "Name"
    value               = "BatchContainerInstance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
