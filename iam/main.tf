provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# Crée un utilisateur IAM
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

# MFA Policy
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
        Sid: "BlockMostAccessUnlessMFAPresent",
        Effect: "Deny",
        Action: "*",
        Resource: "*",
        Condition: {
          BoolIfExists: {
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

# TEMP ADMIN ROLE
resource "aws_iam_role" "temp_admin_role" {
  name = "tf-temp-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "*"
        },
        Action = "sts:AssumeRole",
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent": "true"
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

# FLOW LOGS / FIREHOSE ROLES
resource "aws_iam_role" "flow_logs_role" {
  name = "tf-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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

resource "aws_iam_role" "firehose_role" {
  name = "firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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

resource "aws_iam_policy_attachment" "firehose_policy_attach" {
  name       = "firehose-s3-access"
  roles      = [aws_iam_role.firehose_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
