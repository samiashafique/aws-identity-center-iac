# Analysts
resource "aws_ssoadmin_permission_set" "analytics_permissions" {
  name             = "DataReadOnly"
  description      = "Provides temporary read-only access to user data for analysis"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}
# Renamed from "permissions"; keeps the existing permission set instead of replacing it.
moved {
  from = aws_ssoadmin_permission_set.permissions
  to   = aws_ssoadmin_permission_set.analytics_permissions
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
  permission_set_arn = aws_ssoadmin_permission_set.analytics_permissions.arn
}

# Platform
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

# Operations
resource "aws_ssoadmin_permission_set" "operations_permissions" {
  name             = "EC2-CW-SSM-RDS-Full"
  description      = "Short-lived full access for operations engineers"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "operations_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccessV2",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
  ])

  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.operations_permissions.arn
}

# Finance
resource "aws_ssoadmin_permission_set" "finance_permissions" {
  name             = "Billing-Budget-Management"
  description      = "Manage billing and budgets and use Cost Explorer"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "finance_policies" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
  permission_set_arn = aws_ssoadmin_permission_set.finance_permissions.arn
}

# Developers
resource "aws_ssoadmin_permission_set" "development_permissions" {
  name             = "EC2-AppAssets-LogsRead"
  description      = "Manage EC2, read and write application asset files, and view CloudWatch logs"
  instance_arn     = local.instance_arn
  session_duration = "PT1H"
}

resource "aws_ssoadmin_managed_policy_attachment" "development_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess",
  ])

  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.development_permissions.arn
}

data "aws_iam_policy_document" "app_assets" {
  statement {
    sid       = "ListAppAssetsBucket"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${local.app_assets_bucket}"]
  }

  statement {
    sid       = "ReadWriteAppAssetsObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${local.app_assets_bucket}/*"]
  }
}

resource "aws_ssoadmin_permission_set_inline_policy" "app_assets" {
  inline_policy      = data.aws_iam_policy_document.app_assets.json
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.development_permissions.arn
}
