#-----------------------------------
# AWS
#-----------------------------------
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "this" {
  count = length(var.iam_policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.iam_policy_statements

    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_policy" "this" {
  count = length(var.iam_policy_statements) > 0 ? 1 : 0

  name        = var.name
  description = var.iam_policy_description
  policy      = data.aws_iam_policy_document.this[count.index].json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count = length(var.iam_policy_statements) > 0 ? 1 : 0

  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this[count.index].arn
}

data "aws_iam_policy_document" "trust_relationship" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${var.oidc_provider}"]
    }
    condition {
      test     = "StringLike"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
    // Only allow the service account created to assume the role
    condition {
      test     = "StringLike"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.k8s_namespace}:${var.name}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  description        = var.iam_role_description
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json

  tags = var.tags
}

#-----------------------------------
# Kubernetes
#-----------------------------------
resource "kubernetes_service_account_v1" "this" {
  metadata {
    name      = var.name
    namespace = var.k8s_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.this.arn
    }
  }

  depends_on = [aws_iam_role.this]
}
