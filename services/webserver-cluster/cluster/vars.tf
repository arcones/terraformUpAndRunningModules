variable "server_port" {}
variable "instance_type" {}
variable "min_size" {}
variable "max_size" {}
variable "elb_id" {}
variable "cluster_name" {}
variable "db_remote_state_bucket" {}
variable "db_remote_state_key" {}
variable "enable_new_user_data" {}

variable "ami" {
  default = "ami-0fad7824ed21125b1"
}

variable "availability_zones_names" {
  type = "list"
}
