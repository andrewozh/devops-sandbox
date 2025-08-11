module "iam_user" {
  for_each = toset(var.users)

  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "5.32.0"

  name                    = each.key
  force_destroy           = true
  password_reset_required = false
  create_iam_access_key   = false
}
