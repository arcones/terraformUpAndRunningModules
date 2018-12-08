data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-central-1"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}

resource "aws_launch_configuration" "ubuntu" {
  image_id        = "ami-0fad7824ed21125b1"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.security_group_ec2.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "scaling_group" {
  launch_configuration = "${aws_launch_configuration.ubuntu.id}"
  availability_zones   = ["${var.availability_zones_names}"]

  load_balancers    = ["${var.elb_id}"]
  health_check_type = "ELB"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  tags = {
    key                 = "Name"
    value               = "terraformUpAndRunning-${var.cluster_name}"
    propagate_at_launch = true
  }

  wait_for_capacity_timeout = "5m"
}

resource "aws_security_group" "security_group_ec2" {
  name        = "security-group-${var.cluster_name}"
  description = "Security group for AWS EC2 instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = "${aws_security_group.security_group_ec2.id}"

  from_port   = "${var.server_port}"
  to_port     = "${var.server_port}"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_autoscaling_schedule" "scale_out_during_bussiness_hours" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale_out_during_bussiness_hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.scaling_group.name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale_in_at_night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.scaling_group.name}"
}
