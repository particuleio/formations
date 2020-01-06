resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this[0].name
  policy_arn = var.policy
}
