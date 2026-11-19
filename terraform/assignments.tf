resource "aws_ssoadmin_account_assignment" "groups_assignment" {
  for_each     = local.assignments
  instance_arn = local.instance_arn

  principal_id   = aws_identitystore_group.teams[each.key].group_id
  principal_type = "GROUP"

  permission_set_arn = each.value.permission_set_arn

  target_id   = each.value.target_id
  target_type = "AWS_ACCOUNT"
}

moved {
  from = aws_ssoadmin_account_assignment.analyst_group_assignment
  to   = aws_ssoadmin_account_assignment.groups_assignment["Analysts"]
}
moved {
  from = aws_ssoadmin_account_assignment.platform_admin_assignment
  to   = aws_ssoadmin_account_assignment.groups_assignment["Platform"]
}
moved {
  from = aws_ssoadmin_account_assignment.operations_assignment
  to   = aws_ssoadmin_account_assignment.groups_assignment["Operations"]
}
moved {
  from = aws_ssoadmin_account_assignment.finance_assignment
  to   = aws_ssoadmin_account_assignment.groups_assignment["Finance"]
}
