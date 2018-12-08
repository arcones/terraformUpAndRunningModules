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

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["Cloudwatch:Describe*", "Cloudwatch:Get*", "Cloudwatch:List*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name   = "cloudwatch_read_only"
  policy = "${data.aws_iam_policy_document.cloudwatch_read_only.json}"
}

resource "aws_iam_user_policy_attachment" "cloudwatch_read_only_alicia" {
  count      = "${1 - var.alicia_cloudwatch_full_access}"
  name       = "cloudwatch_read_only_alicia"
  policy_arn = "${aws_iam_policy.cloudwatch_read_only.arn}"
  user       = "${var.user_names[0]}"
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["Cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch_full_access"
  policy = "${data.aws_iam_policy_document.cloudwatch_full_access.json}"
}

resource "aws_iam_user_policy_attachment" "cloudwatch_full_access_alicia" {
  count      = "${var.alicia_cloudwatch_full_access}"
  name       = "cloudwatch_full_access_alicia"
  policy_arn = "${aws_iam_policy.cloudwatch_read_only.arn}"
  user       = "${var.user_names[0]}"
}
