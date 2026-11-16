# Identity Center must be enabled manually in the console; Terraform only looks up the existing instance.
data "aws_ssoadmin_instances" "this" {}

locals {
  # An organization has a single Identity Center instance, so the first element is always the one we need.  
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  teams = {
    Developers = "Engineers who build and deploy the application"
    Operations = "Engineers who run and maintain the infrastructure"
    Finance    = "Staff who track cloud costs and budgets"
    Analysts   = "Data analysts who query application data"
  }

}

resource "aws_identitystore_group" "teams" {
  for_each = local.teams

  display_name      = each.key
  description       = each.value
  identity_store_id = local.identity_store_id

}

