resource "aws_ssoadmin_permission_set" "permissions" {
  name             = "DataReadOnly"
  description      = "Provides temporary read-only access to user data for analysis"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

data "aws_iam_policy_document" "s3_read_only" {
  statement {
    sid       = "ListAnalyticsBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.analytics_bucket}"]
  }

  statement {
    sid       = "ReadAnalyticsObjects"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.analytics_bucket}/*"]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "userdata_analytics" {
  inline_policy      = data.aws_iam_policy_document.s3_read_only.json
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permissions.arn
}

resource "aws_ssoadmin_permission_set" "platform_permissions" {
  name             = "AdminAccess"
  description      = "Short-lived full administrative access for platform engineers"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "platform_admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.platform_permissions.arn
}
