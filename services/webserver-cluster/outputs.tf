output "elb_dns_name" {
  value = "${module.elb.dns_name}"
}

output "auto_scaling_group_name" {
  value = "${module.cluster.auto_scaling_group_name}"
}

output "elb_security_group_id" {
  value = "${module.elb.security_group_id}"
}

output "ec2_security_group_id" {
  value = "${module.cluster.security_group_id}"
}

output "script_used" {
  value = "${module.cluster.script_used}"
}