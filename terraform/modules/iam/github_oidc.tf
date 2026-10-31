# GitHub Actions -> AWS using OIDC federation: CI assumes an IAM *role* with a
# short-lived token, so no IAM user and no long-lived access keys are needed.
# Everything here is skipped unless var.github_repository is set.

variable "github_repository" {
  description = "GitHub repository allowed to assume the CI role, as OWNER/REPO (case-sensitive). Empty disables the CI role."
  type        = string
  default     = ""
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if token.actions.githubusercontent.com already exists in this account."
  type        = bool
  default     = true
}

locals {
  github_ci_enabled = var.github_repository != ""
  github_oidc_url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = local.github_ci_enabled && var.create_github_oidc_provider ? 1 : 0

  url            = local.github_oidc_url
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
  tags = var.tags
}

data "aws_iam_openid_connect_provider" "github" {
  count = local.github_ci_enabled && !var.create_github_oidc_provider ? 1 : 0

  url = local.github_oidc_url
}

locals {
  github_oidc_provider_arn = local.github_ci_enabled ? (
    var.create_github_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : data.aws_iam_openid_connect_provider.github[0].arn
  ) : ""
}

data "aws_iam_policy_document" "github_ci_assume" {
  count = local.github_ci_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only this repo, and only runs on main or from pull requests (CI builds PRs too).
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:ref:refs/heads/main",
        "repo:${var.github_repository}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_ci" {
  count = local.github_ci_enabled ? 1 : 0

  name               = "${var.name}-github-ci"
  assume_role_policy = data.aws_iam_policy_document.github_ci_assume[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "github_ci_ecr" {
  count = local.github_ci_enabled ? 1 : 0

  role       = aws_iam_role.github_ci[0].name
  policy_arn = aws_iam_policy.ecr_push.arn
}
