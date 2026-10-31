output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "ARN of the EKS worker node IAM role."
  value       = aws_iam_role.node.arn
}

output "ecr_push_policy_arn" {
  description = "ARN of the ECR push policy for CI."
  value       = aws_iam_policy.ecr_push.arn
}

output "github_ci_role_arn" {
  description = "IAM role assumed by GitHub Actions via OIDC (empty if github_repository is unset)."
  value       = try(aws_iam_role.github_ci[0].arn, "")
}
