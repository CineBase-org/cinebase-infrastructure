output "ecs_ec2_sg_id" {
  value = aws_security_group.ecs-ec2-sg.id
}

output "backend_cluster_name" {
  value = aws_ecs_cluster.backend_cluster.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend.name
}

output "backend_asg_name" {
  value = aws_autoscaling_group.auto_scaling_group.name
}

output "esc_cluster_name" {
  value = aws_ecs_cluster.backend_cluster.name
}

output "esc_service_name" {
  value = aws_ecs_service.backend.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_service_arn" {
  value = aws_ecs_service.backend.arn
}

output "ecs_task_definition_arn_without_revision" {
  value = aws_ecs_task_definition.task_definition.arn_without_revision
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.backend_cluster.arn
}