variable "enabled" {
  type    = bool
  default = false
}

resource "aws_ecs_task_definition" "ecs_task" {
  count = var.enabled ? 1 : 0

  requires_compatibilities = ["FARGATE"]
  family                   = "ecs_task_module_1"
  memory                   = "2 GB"
  cpu                      = "1 vCPU"

  container_definitions = <<TASK_DEFINITION
			[
				{
						"command": ["sleep", "10"],
						"entryPoint": ["/"],
						"essential": true,
						"image": "alpine",
						"name": "alpine",
						"network_mode": "none"
				}
			]
			TASK_DEFINITION
}

resource "aws_ecs_service" "ecs_service" {
  count = var.enabled ? 1 : 0

  name            = "ecs_service_module_1"
  launch_type     = "FARGATE"
  task_definition = "${join("", aws_ecs_task_definition.ecs_task.*.family)}:${join("", aws_ecs_task_definition.ecs_task.*.revision)}"
  desired_count   = 1
}

module "module2" {
  source  = "./modules/module2"
  enabled = true
}
