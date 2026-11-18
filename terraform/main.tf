# Identity Center must be enabled manually in the console; Terraform only looks up the existing instance.
data "aws_ssoadmin_instances" "this" {}

# Terraform runs in the management account, so the caller's account is the management account.
data "aws_caller_identity" "management_account" {}

locals {
  # An organization has a single Identity Center instance, so the first element is always the one we need.
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  # Group display name = description.
  teams = {
    Developers = "Engineers who build and deploy the application"
    Operations = "Engineers who run and maintain the infrastructure"
    Finance    = "Staff who track cloud costs and budgets"
    Analysts   = "Data analysts who query application data"
    Platform   = "Engineers who administer the AWS accounts"
  }

  # Keyed by username. "team" must match a key in teams.
  users = {
    "maya.smith"     = { first_name = "Maya", last_name = "Smith", team = "Developers" }
    "daniel.grey"    = { first_name = "Daniel", last_name = "Grey", team = "Developers" }
    "ali.noor"       = { first_name = "Ali", last_name = "Noor", team = "Developers" }
    "zoya.ehsan"     = { first_name = "Zoya", last_name = "Ehsan", team = "Developers" }
    "noah.bennett"   = { first_name = "Noah", last_name = "Bennett", team = "Operations" }
    "hannah.kim"     = { first_name = "Hannah", last_name = "Kim", team = "Operations" }
    "omar.farooq"    = { first_name = "Omar", last_name = "Farooq", team = "Finance" }
    "sofia.alvarez"  = { first_name = "Sofia", last_name = "Alvarez", team = "Analysts" }
    "wei.zhang"      = { first_name = "Wei", last_name = "Zhang", team = "Analysts" }
    "trevor.white"   = { first_name = "Trevor", last_name = "White", team = "Analysts" }
    "samia.shafique" = { first_name = "Samia", last_name = "Shafique", team = "Platform" }
  }

  analytics_bucket = "analytics-bucket-ss"
}

resource "aws_identitystore_group" "teams" {
  for_each = local.teams

  identity_store_id = local.identity_store_id
  display_name      = each.key
  description       = each.value
}

resource "aws_identitystore_user" "user" {
  for_each = local.users

  identity_store_id = local.identity_store_id

  display_name = "${each.value.first_name} ${each.value.last_name}"
  user_name    = each.key

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }
}

resource "aws_identitystore_group_membership" "membership" {
  for_each = local.users

  identity_store_id = local.identity_store_id

  group_id  = aws_identitystore_group.teams[each.value.team].group_id
  member_id = aws_identitystore_user.user[each.key].user_id
}
