# Identity Center must be enabled manually in the console; Terraform only looks up the existing instance.
data "aws_ssoadmin_instances" "this" {}

# An organization has a single Identity Center instance, so the first element is always the one we need.
locals {
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

}