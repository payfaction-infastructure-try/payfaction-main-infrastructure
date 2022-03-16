variable "aws_resource_name_prefix" {
  description = "Prefix to be used in the naming of some of the created AWS resources e.g. demo-webapp"
} 

variable "vpc_id" {}
variable "load_balancer_id" {}
variable "load_balancer_security_group_id" {}
variable "cluster_id" {}
variable "private_subnets" {}