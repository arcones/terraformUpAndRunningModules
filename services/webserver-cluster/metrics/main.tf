resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  count       = "${format("%.1s", var.instance_type) == "t" ? 1 : 0}"
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions {
    AutoScalingGroupName = "${var.auto_scaling_group_name}"
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
