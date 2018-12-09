resource "aws_autoscaling_schedule" "scale_out_during_bussiness_hours" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale_out_during_bussiness_hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = "${var.auto_scaling_group_name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count                 = "${var.enable_autoscaling}"
  scheduled_action_name = "scale_in_at_night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = "${var.auto_scaling_group_name}"
}
