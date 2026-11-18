# Analysts
resource "aws_ssoadmin_account_assignment" "analyst_group_assignment" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.analytics_permissions.arn

  principal_id   = aws_identitystore_group.teams["Analysts"].group_id
  principal_type = "GROUP"

  target_id   = var.workloads_prod_account_id
  target_type = "AWS_ACCOUNT"
}

# Platform
resource "aws_ssoadmin_account_assignment" "platform_admin_assignment" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_permissions.arn

  principal_id   = aws_identitystore_group.teams["Platform"].group_id
  principal_type = "GROUP"

  target_id   = var.workloads_prod_account_id
  target_type = "AWS_ACCOUNT"
}

# Operations
resource "aws_ssoadmin_account_assignment" "operations_assignment" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.operations_permissions.arn

  principal_id   = aws_identitystore_group.teams["Operations"].group_id
  principal_type = "GROUP"

  target_id   = var.workloads_prod_account_id
  target_type = "AWS_ACCOUNT"
}

# Finance
resource "aws_ssoadmin_account_assignment" "finance_assignment" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.finance_permissions.arn

  principal_id   = aws_identitystore_group.teams["Finance"].group_id
  principal_type = "GROUP"

  target_id   = data.aws_caller_identity.management_account.account_id
  target_type = "AWS_ACCOUNT"
}