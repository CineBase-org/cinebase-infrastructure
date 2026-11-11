output "alb_sg_id" {
  value = aws_security_group.alb-sg.id
}

output "alb_sg_arn" {
  value = aws_security_group.alb-sg.arn
}

output "alb_dns_name" {
  value = aws_lb.lb_backend.dns_name
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.blue.arn
}
output "green_target_group_arn" {
  value = aws_lb_target_group.green.arn
}

output "production_listener_rule_arn" {
  value = aws_lb_listener_rule.production.arn
}

output "alb_arn_suffix" {
  value = aws_lb.lb_backend.arn_suffix
}

output "blue_target_group_arn_suffix" {
  value = aws_lb_target_group.blue.arn_suffix
}

output "green_target_group_arn_suffix" {
  value = aws_lb_target_group.green.arn_suffix
}

output "smoke_test_listener_rule_arn" {
  value = aws_lb_listener_rule.smoke_test.arn
}