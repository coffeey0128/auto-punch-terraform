resource "aws_iam_policy" "iam_random_time_sqs" {
  name = "random-time-sqs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Effect" = "Allow",
      "Action" = "sqs:SendMessage",
      Resource = module.sqs_punch_dalay.sqs_queue_arn
    }]
  })
}

// random-time lambda can send msg to sqs
resource "aws_iam_role_policy_attachment" "iam_random_time_sqs" {
  role       = module.lambda_random_time.lambda_role_name
  policy_arn = aws_iam_policy.iam_random_time_sqs.arn
}


// sqs can trigger auto-punch lambda
resource "aws_iam_role_policy_attachment" "lambda_sqs_role_policy" {
  role       = module.lambda_auto_punch.lambda_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}


resource "aws_iam_policy" "iam_sns_punch_status" {
  name = "iam-sns-punch-status"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Effect" = "Allow",
      "Action" = "sns:Publish",
      Resource = aws_sns_topic.sns_punch_status.arn
    }]
  })
}


// auto-punch lambda can send msg to sns
resource "aws_iam_role_policy_attachment" "iam_sns_punch_status" {
  role       = module.lambda_auto_punch.lambda_role_name
  policy_arn = aws_iam_policy.iam_sns_punch_status.arn
}