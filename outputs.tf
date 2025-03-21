output "role_id" {
  value = aws_iam_role.devops.arn
}

output "role_id_devops-dev" {
  value = aws_iam_role.devops-dev.arn

}

output "role_id_devops-prod" {
  value = aws_iam_role.devops-prod.arn

}