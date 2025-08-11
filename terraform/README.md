# terraform

Using `Terragrunt` to provision infra

## terragrunt

* run multiple modules at once (from dir with `account.hcl` to run all modules for account)

```
cd andrewozh
terragrunt run-all plan
```

* altinity

## infracost

* to see coast value of current infra

```
brew install infracost
infracost auth login
infracost configure set api_key ico-XXX
infracost breakdown --path .
```

* set `avoid_billing` to `true` in `account.hcl` and apply to remove paid resources

## helm

* replace with `jsonnet` or `cue`

## iam

### users

* list of users specified in `<account_name>/account.hcl`
* terragrunt module `<account_name>/_global/_global/iam_users/terragrunt.hcl`
* dynamically run terraform module in `_modules/iam/user/module.tf` for every specified user
* example how to import current manually created amdin user

```
cd andrewozh/_global/_global/iam_users
terragrunt init
terragrunt plan
terragrunt import 'module.iam_user["andrew.ozhegov"].aws_iam_user.this[0]' andrew.ozhegov
terragrunt import 'module.iam_user["andrew.ozhegov"].aws_iam_user_login_profile.this[0]' andrew.ozhegov
terragrunt apply
```

### groups

* configuring same as users
* required manual import of already existing group

```
terragrunt import 'module.iam_group["admin"].aws_iam_group.this[0]' admin
```

## vpc

* using `terraform-aws-modules/vpc/aws` because it's awesome
* vpc peering using `cloudposse/vpc-peering`

## eks

### Karpetner

autoscaling cluster nodes

### ArgoCD

* most simple implementation for now
* access ui (`yq` required)

```
kubectl port-forward svc/argocd-server -n argocd 8080:80
# login: admin
# password:
kubectl get secrets argocd-initial-admin-secret -o yaml -n argocd | yq .data.password | base64 --decode
```
