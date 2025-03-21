resource "aws_iam_account_alias" "alias-main" {
  account_alias = "endritrugova-main"
}
resource "aws_iam_account_alias" "alias-dev" {
  account_alias = "endritrugova-dev"
  provider      = aws.dev

}

resource "aws_iam_account_alias" "alias-prod" {
  account_alias = "endritrugova-prod"
  provider      = aws.prod

}

resource "aws_iam_group" "devops-group" {
  name = local.group
}
resource "aws_iam_user" "devops" {

  for_each = toset(local.users)
  name     = each.value
}

resource "aws_iam_group_membership" "devops" {
  name = "devops"

  users      = local.users
  group      = local.group
  depends_on = [aws_iam_user.devops, aws_iam_group.devops-group]

}
resource "aws_iam_role" "devops" {
  name = "devops"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = ["arn:aws:iam::833909750015:user/admin", "arn:aws:iam::833909750015:user/devops", "arn:aws:iam::833909750015:user/tali"]
        }
      },
    ]
  })
  depends_on = [aws_iam_user.devops, aws_iam_group.devops-group]
}
resource "aws_iam_role_policy_attachment" "devops" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.devops.name
  depends_on = [aws_iam_role.devops]

}

resource "aws_iam_role" "devops-dev" {
  name = "devops"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = ["arn:aws:iam::833909750015:user/admin", "arn:aws:iam::833909750015:user/devops", "arn:aws:iam::833909750015:user/tali"]
        }
      },
    ]
  })
  depends_on = [aws_iam_user.devops, aws_iam_group.devops-group]
  provider   = aws.dev
}
resource "aws_iam_role_policy_attachment" "devops-dev" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.devops-dev.name
  depends_on = [aws_iam_role.devops]
  provider   = aws.dev

}

data "aws_iam_policy_document" "devops" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::833909750015:user/admin", "arn:aws:iam::833909750015:user/devops", "arn:aws:iam::833909750015:user/tali"
      ]
    }
  }
  # data "aws_iam_policy_document" "role_trust_policy" {
  #   statement {
  #     actions   = ["sts:AssumeRole"]
  #     principals {
  #       type        = "AWS"
  #       identifiers = flatten([
  #         for user in aws_iam_group_membership.devops_membership.users : 
  #           "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${user}"
  #       ])
  #     }
  #   }
  # }

  provider = aws.prod
}
resource "aws_iam_role" "devops-prod" {
  name               = "devops"
  assume_role_policy = data.aws_iam_policy_document.devops.json
  provider           = aws.prod

}
resource "aws_iam_role_policy_attachment" "devops-prod" {
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  role       = aws_iam_role.devops-prod.name
  provider   = aws.prod
  depends_on = [aws_iam_role.devops-prod]

}