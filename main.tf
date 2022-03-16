data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

data "aws_ecr_repository" "app_repo" {
  name = "${local.aws_ecr_repository_name}"
}


resource "aws_lb_target_group" "app_tg" {
  name        = "${local.aws_alb_target_group_name}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = var.load_balancer_id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.app_tg.id
    type             = "forward"
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
        "image": "${data.aws_ecr_repository.app_repo.repository_url}",
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

resource "aws_security_group" "app_sg" {
  name        = "${local.aws_ecs_service_security_group_name}"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [var.load_balancer_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app_ecs_service" {
  name            = "${local.aws_ecs_service_name}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app_task_def.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.app_sg.id]
    subnets         = var.private_subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.id
    container_name   = "${local.aws_ecs_service_name}"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.app_listener]
}

