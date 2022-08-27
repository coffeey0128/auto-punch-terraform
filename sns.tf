resource "aws_sns_topic" "sns_punch_status" {
  name = "punch-status"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn = aws_sns_topic.sns_punch_status.arn
  protocol  = "email"
  endpoint  = var.email_root_user
}