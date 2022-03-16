
locals {
  aws_ecr_repository_name = "${var.aws_resource_name_prefix}"

  aws_ecs_service_name = "${var.aws_resource_name_prefix}-service"

  aws_ecs_service_security_group_name = "${var.aws_resource_name_prefix}-ecs-service-security-group"

  aws_alb_target_group_name = "${var.aws_resource_name_prefix}-alb-target-group"
}