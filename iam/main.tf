resource "aws_iam_user" "kungfu_user" {
  name          = "tf-${var.username}-user"
  force_destroy = true
}

resource "aws_iam_access_key" "kungfu_access_key" {
  user = aws_iam_user.kungfu_user.name
}

data "aws_iam_policy" "full_read_only_policy" {
  name = "ReadOnlyAccess"
}

resource "aws_iam_policy_attachment" "attach_full_read_only" {
  name       = "tf-attach-readonly"
  users      = [aws_iam_user.kungfu_user.name]
  policy_arn = data.aws_iam_policy.full_read_only_policy.arn
}

resource "aws_iam_user_policy" "kungfu_policy" {
  name = "tf-${var.policy_name}-policy"
  user = aws_iam_user.kungfu_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:AttachUserPolicy",
          "iam:CreateUser"
        ],
        "Resource" : [
          "arn:aws:iam::421751520950:user/fake-admin*",
          "arn:aws:iam::421751520950:policy/tf-fake-admin-policy"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "fake_admin_policy" {
  name = "tf-fake-admin-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances" # TODO : A CHANGER
        ],
        "Resource" : "*"
      }
    ]
  })
}

## PART 4
resource "aws_iam_user" "users" {
  for_each      = toset(var.usernames)
  name          = "tf-${each.key}-user"
  force_destroy = true
}

resource "aws_iam_group" "all_users_group" {
  name = "tf-all-users-group"
}

resource "aws_iam_policy" "enforce_mfa_policy" {
  name        = "tf-enforce-mfa"
  description = "Deny all actions unless MFA is enabled"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "BlockMostAccessUnlessMFAPresent",
        "Effect": "Deny",
        "Action": "*",
        "Resource": "*",
        "Condition": {
          "BoolIfExists": {
            "aws:MultiFactorAuthPresent": "false"
          }
        }
      }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "enforce_mfa_group_attachment" {
  group      = aws_iam_group.all_users_group.name
  policy_arn = aws_iam_policy.enforce_mfa_policy.arn
}

resource "aws_iam_user_group_membership" "group_membership" {
  for_each = aws_iam_user.users

  user   = each.value.name
  groups = [aws_iam_group.all_users_group.name]
}

## TEMP ADMIN ROLE
# commande a executer pour tester : 
# aws sts assume-role  --role-arn arn:aws:iam::935610067208:role/tf-temp-admin-role   --role-session-name temp-admin-session --serial-number {run this command to get arn aws iam list-mfa-devices --user-name tf-test1-user}  --token-code {code_app_mfa} --profile test1-user

resource "aws_iam_user_policy" "allow_assume_temp_admin" {
  name = "allow-assume-temp-admin"
  user = "tf-test1-user"  # a variabiliser 

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = aws_iam_role.temp_admin_role.arn
      }
    ]
  })
}

resource "aws_iam_role" "temp_admin_role" {
  name = "tf-temp-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::935610067208:user/tf-test1-user" # a variabiliser 
        },
        Action = "sts:AssumeRole",
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach_to_temp_role" {
  role       = aws_iam_role.temp_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
