module "iam_group" {
  for_each = local.groups_map

  source = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.32.0"

  name = each.key
  path = "/${each.key}/"

  group_users = [for user in var.users : user.name if contains(user.groups, each.key)]

  custom_group_policy_arns = each.value.policy_arns

  custom_group_policies = []

  enable_mfa_enforcement = false
}
