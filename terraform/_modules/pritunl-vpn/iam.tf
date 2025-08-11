# TODO: in case there is an elegant solution to avoid cycle on line 15
# "AWS" : "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/pritunl/${data.aws_instance.pritunl.id}"
resource "aws_iam_role" "pritunl" {
  name = "pritunl"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com",
          "AWS" : "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/pritunl/i-XXXXXXXXXXXXXXX"
        },
        "Effect" : "Allow"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_instance_profile" "pritunl" {
  name = "pritunl"
  role = aws_iam_role.pritunl.name
}

resource "aws_iam_role_policy" "pritunl" {
  name = "pritunl"
  role = aws_iam_role.pritunl.id
  #tfsec:ignore:aws-iam-no-policy-wildcards
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupIngress"
        ],
        "Resource" : [
          aws_security_group.pritunl.arn,
          replace(aws_security_group.pritunl.arn, "security-group", "security-group-rule")
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "ec2:DescribeSecurityGroups",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones",
          "route53:GetChange"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : [
          data.aws_route53_zone.selected.arn
        ]
      }
    ]
  })
}
