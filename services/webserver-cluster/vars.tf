variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = "8080"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the S· bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "instance_type" {
  description = "Type of the EC2 instances to run (e.g, t2.micro)"
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the auto scaling group"
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the auto scaling group"
}

variable "enable_autoscaling" {}
