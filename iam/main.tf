resource "aws_iam_user" "kungfu_user" {
  name          = "tf-${var.username}-user"
  force_destroy = true
}

resource "aws_iam_access_key" "kungfu_access_key" {
  user = aws_iam_user.kungfu_user.name
}

resource "aws_iam_policy_attachment" "attach_full_read_only" {
  name       = "tf-attach-readonly"
  users      = [aws_iam_user.kungfu_user.name]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
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
          "ec2:DescribeInstances" # TODO : A CHANGER
        ],
        "Resource" : "*"
      }
    ]
  })
}

## PART 4

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

resource "aws_iam_role" "temp_admin_role" {
  name = "tf-temp-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
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

resource "aws_iam_role_policy_attachment" "admin_attach_to_temp_role" {
  role       = aws_iam_role.temp_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

## dynamic edits 
# Part 2: Create IAM Users
resource "aws_iam_user" "users" {
  for_each = var.user_groups
  name     = "tf-${each.key}-user"
  force_destroy = true
}

# Part 3: Create IAM Groups
resource "aws_iam_group" "groups" {
  for_each = toset(flatten([for user, groups in var.user_groups : groups]))
  name     = "tf-${each.value}-group"
}

# Part 4: Attach Users to Groups
resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = var.user_groups
  user     = aws_iam_user.users[each.key].name
  groups   = [for group in each.value : aws_iam_group.groups[group].name]
}

# Part 5: Create IAM Policies
resource "aws_iam_policy" "policies" {
  for_each = toset(flatten([for user, policies in var.user_policies : policies]))
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

# Part 6: Attach Policies to Users
resource "aws_iam_policy_attachment" "policy_attachment" {
  for_each = var.user_policies
  name     = "tf-attach-${each.key}-policies"
  users    = [aws_iam_user.users[each.key].name]
  policy_arn = aws_iam_policy.policies[each.value[0]].arn
}

## Déclaration des rôles manquants : flow_logs_role et firehose_delivery_role

resource "aws_iam_role" "flow_logs_role" {
  name = "tf-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "firehose_delivery_role" {
  name = "tf-firehose-delivery-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}