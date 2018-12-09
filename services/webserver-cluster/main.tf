data "aws_availability_zones" "all" {}

module "cluster" {
  source                   = "cluster"
  cluster_name             = "${var.cluster_name}"
  db_remote_state_bucket   = "${var.db_remote_state_bucket}"
  db_remote_state_key      = "${var.db_remote_state_key}"
  server_port              = "${var.server_port}"
  instance_type            = "${var.instance_type}"
  min_size                 = "${var.min_size}"
  max_size                 = "${var.max_size}"
  elb_id                   = "${module.elb.id}"
  availability_zones_names = "${data.aws_availability_zones.all.names}"
  enable_new_user_data     = "${var.enable_new_user_data}"
}

module "elb" {
  source                   = "elb"
  cluster_name             = "${var.cluster_name}"
  server_port              = "${var.server_port}"
  availability_zones_names = "${data.aws_availability_zones.all.names}"
  open_testing_port        = "${var.open_testing_port}"
}

module "scaling" {
  source                  = "scaling"
  enable_autoscaling      = "${var.enable_autoscaling}"
  auto_scaling_group_name = "${module.cluster.auto_scaling_group_name}"
}

module "metrics" {
  source                        = "metrics"
  cluster_name                  = "${var.cluster_name}"
  auto_scaling_group_name       = "${module.cluster.auto_scaling_group_name}"
  instance_type                 = "${var.instance_type}"
  alicia_cloudwatch_full_access = "${var.alicia_cloudwatch_full_access}"
  user_names                    = "${var.user_names}"
}
