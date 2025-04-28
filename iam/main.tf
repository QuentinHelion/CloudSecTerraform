#########################################
# IAM USER (Static user pour base)
#########################################

resource "aws_iam_user" "kungfu_user" {
  name          = "tf-${var.username}-user"
  force_destroy = true
  tags = {
    Name = "tf-${var.username}-user"
  }
}

resource "aws_iam_access_key" "kungfu_access_key" {
  user = aws_iam_user.kungfu_user.name
}

#########################################
# ATTACH AWS READONLY POLICY
#########################################

resource "aws_iam_policy_attachment" "attach_full_read_only" {
  name       = "tf-attach-readonly"
  users      = [aws_iam_user.kungfu_user.name]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#########################################
# IAM POLICY FOR FAKE ADMIN
#########################################

data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy" "kungfu_policy" {
  name = "tf-${var.policy_name}-policy"
  user = aws_iam_user.kungfu_user.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:AttachUserPolicy",
          "iam:CreateUser"
        ],
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/fake-admin*",
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/tf-fake-admin-policy"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "fake_admin_policy" {
  name = "tf-fake-admin-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

#########################################
# IAM POLICY FOR CLOUDTRAIL
#########################################

resource "aws_iam_policy" "cloudtrail_policy" {
  name        = "kungfu-cloudtrail-policy"
  description = "Allow CloudTrail to write to S3 and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

#########################################
# DYNAMIC IAM USERS
#########################################

resource "aws_iam_user" "users" {
  for_each     = var.user_groups
  name         = "tf-${each.key}-user"
  force_destroy = true

  tags = {
    Name = "tf-${each.key}-user"
  }
}

#########################################
# DYNAMIC IAM GROUPS
#########################################

resource "aws_iam_group" "groups" {
  for_each = toset(flatten([for user, groups in var.user_groups : groups if length(groups) > 0]))
  name     = "tf-${each.value}-group"
}

#########################################
# ATTACH USERS TO GROUPS
#########################################

resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = var.user_groups

  user   = aws_iam_user.users[each.key].name
  groups = [for group in each.value : aws_iam_group.groups[group].name]
}

#########################################
# DYNAMIC IAM POLICIES (1 per policy name)
#########################################

resource "aws_iam_policy" "policies" {
  for_each = toset(flatten([for user, policies in var.user_policies : policies if length(policies) > 0]))
  name     = each.value
  policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "*",
        Resource = "*"
      }
    ]
  })
}

#########################################
# 📎 ATTACH POLICIES TO USERS
#########################################

resource "aws_iam_policy_attachment" "policy_attachment" {
  for_each = var.user_policies

  name       = "tf-attach-${each.key}-policies"
  users      = [aws_iam_user.users[each.key].name]
  policy_arn = aws_iam_policy.policies[each.value[0]].arn
}

#########################################
# MFA ENFORCEMENT FOR ALL USERS
#########################################

resource "aws_iam_group" "all_users_group" {
  name = "tf-all-users-group"
}

resource "aws_iam_policy" "enforce_mfa_policy" {
  name        = "tf-enforce-mfa"
  description = "Deny all actions unless MFA is enabled"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "BlockMostAccessUnlessMFAPresent",
        Effect = "Deny",
        Action = "*",
        Resource = "*",
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
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

#########################################
# TEMP ADMIN ROLE WITH MFA
#########################################

resource "aws_iam_role" "temp_admin_role" {
  name = "tf-temp-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "*"
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

resource "aws_iam_user_policy" "allow_assume_temp_admin" {
  name = "allow-assume-temp-admin-${var.assume_role_user}"
  user = aws_iam_user.users[var.assume_role_user].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = aws_iam_role.temp_admin_role.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach_to_temp_role" {
  role       = aws_iam_role.temp_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
