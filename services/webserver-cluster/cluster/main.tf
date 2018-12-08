data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-central-1"
  }
}

data "template_file" "user_data" {
  count    = "${1 - var.enable_new_user_data}"
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
    server_text = "Hello from OLD user data"
  }
}

data "template_file" "user_data_new" {
  count    = "${var.enable_new_user_data}"
  template = "${file("${path.module}/user-data-new.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
    server_text = "Hello from NEW user data"
  }
}

resource "aws_launch_configuration" "ubuntu" {
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.security_group_ec2.id}"]

  user_data = "${element(concat(data.template_file.user_data.*.rendered, data.template_file.user_data_new.*.rendered),0)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "scaling_group" {
  name = "${var.cluster_name}-${aws_launch_configuration.ubuntu.name}"
  launch_configuration = "${aws_launch_configuration.ubuntu.id}"
  availability_zones   = ["${var.availability_zones_names}"]

  load_balancers    = ["${var.elb_id}"]
  health_check_type = "ELB"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  min_elb_capacity = "${var.min_size}"

  tags = {
    key                 = "Name"
    value               = "terraformUpAndRunning-${var.cluster_name}"
    propagate_at_launch = true
  }

  wait_for_capacity_timeout = "5m"
  lifecycle {
    create_before_destroy = true
  }
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
