data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecr_repository" "app_repo" {
  name                 = "${local.aws_ecr_repository_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "app_task_def" {
  family                   = "${local.aws_ecs_service_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "${data.aws_iam_role.ecs_task_execution_role.arn}"

  container_definitions = <<DEFINITION
    [
      {
        "essential": true,
        "image": "${aws_ecr_repository.app_repo.repository_url}",
        "cpu": 1024,
        "memory": 2048,
        "name": "${local.aws_ecs_service_name}",
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 80,
            "hostPort": 80,
            "protocol" : "tcp"
          }
        ]
      }
    ]
    DEFINITION
}

resource "aws_ecs_service" "app_ecs_service" {
  name            = "${local.aws_ecs_service_name}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app_task_def.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    security_groups = [var.security_group_id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = var.target_group_id
    container_name   = "${local.aws_ecs_service_name}"
    container_port   = 80
  }

  depends_on = [var.lb_listener]
}

