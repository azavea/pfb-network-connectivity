resource "aws_db_subnet_group" "default" {
  name        = "${var.rds_database_identifier}"
  description = "Private subnets for the RDS instances"
  subnet_ids  = ["${module.vpc.private_subnet_ids}"]

  tags {
    Name        = "dbsngDatabaseServer"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

resource "aws_db_parameter_group" "default" {
  name        = "${var.rds_database_identifier}"
  description = "Parameter group for the RDS instances"
  family      = "${var.rds_parameter_group_family}"

  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_temp_files"
    value = "500"
  }

  parameter {
    name  = "log_autovacuum_min_duration"
    value = "250"
  }

  tags {
    Name        = "dbpgDatabaseServer"
    Project     = "${var.project}"
    Environment = "${var.environment}"
  }
}

module "database" {
  source                     = "github.com/azavea/terraform-aws-postgresql-rds?ref=2.1.0"
  vpc_id                     = "${module.vpc.id}"
  allocated_storage          = "${var.rds_storage_size_gb}"
  engine_version             = "${var.rds_engine_version}"
  instance_type              = "${var.rds_instance_type}"
  storage_type               = "${var.rds_storage_type}"
  database_identifier        = "${var.rds_database_identifier}"
  database_name              = "${var.rds_database_name}"
  database_username          = "${var.rds_username}"
  database_password          = "${var.rds_password}"
  database_port              = "${var.rds_database_port}"
  backup_retention_period    = "${var.rds_backup_retention_period}"
  backup_window              = "${var.rds_backup_window}"
  maintenance_window         = "${var.rds_maintenance_window}"
  multi_availability_zone    = "${var.rds_multi_availability_zone}"
  storage_encrypted          = "${var.rds_sorage_encrypted}"
  auto_minor_version_upgrade = "${var.rds_auto_minor_version_upgrade}"
  subnet_group               = "${aws_db_subnet_group.default.name}"
  parameter_group            = "${aws_db_parameter_group.default.name}"

  alarm_cpu_threshold         = "${var.rds_alarm_cpu_threshold}"
  alarm_disk_queue_threshold  = "${var.rds_alarm_disk_queue_threshold}"
  alarm_free_disk_threshold   = "${var.rds_alarm_free_disk_threshold}"
  alarm_free_memory_threshold = "${var.rds_alarm_free_memory_threshold}"
  alarm_actions               = ["${aws_sns_topic.global.arn}"]

  project     = "${var.project}"
  environment = "${var.environment}"
}
