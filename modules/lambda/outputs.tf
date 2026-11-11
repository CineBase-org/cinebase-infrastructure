output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function_smoke_tests.arn
}

output "ecs_hook_role_arn" {
  value = aws_iam_role.lambda_iam_role_hook.arn

  depends_on = [
    aws_iam_role_policy.ecs_hook_policy
  ]
}