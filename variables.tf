variable "aws_resource_name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources e.g. demo-webapp"
} 

variable "cluster_id" {}
variable "private_subnets" {}
variable "target_group_id" {}
variable "lb_listener" {}
variable "security_group_id" {}
