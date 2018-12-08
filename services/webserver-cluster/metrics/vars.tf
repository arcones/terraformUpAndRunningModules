variable "cluster_name" {}
variable "auto_scaling_group_name" {}
variable "instance_type" {}

variable "user_names" {
  type = "list"
}

variable "alicia_cloudwatch_full_access" {}
