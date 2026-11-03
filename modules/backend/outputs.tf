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