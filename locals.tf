
locals {
  aws_ecr_repository_name = "${var.aws_resource_name_prefix}"
  aws_ecs_service_name = "${var.aws_resource_name_prefix}-service"
}