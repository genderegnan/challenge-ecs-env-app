provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "ecs" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "ecs" {
  vpc_id     = aws_vpc.ecs.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "ecs" {
  vpc_id      = aws_vpc.ecs.id
  name        = "ecs-sg"
  description = "Allow HTTP traffic"

  

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "ecs" {
  name = "ecs-cluster"
}

resource "aws_ecs_task_definition" "ecs" {
  family                   = "ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ecs-app"
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT_NAME"
          value = var.environment_name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "ecs" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.ecs.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [aws_subnet.ecs.id]
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
