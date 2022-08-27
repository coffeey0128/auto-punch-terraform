// Punch in -------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "punch_in_event_rule" {
  name                = "auto-punch-in"
  description         = "Trigger random punch time at 10:00 +0800 "
  //schedule_expression = "cron(0 0 10 ? * MON,TUE,WED,THU,FRI *)"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "punch_in_event_rule_target" {
  arn  = module.lambda_random_time.lambda_function_arn
  rule = aws_cloudwatch_event_rule.punch_in_event_rule.name
}

// Cloudwatch -----------------------------------------------------
resource "aws_lambda_permission" "allow_cloudwatch_to_call_rw_fallout_retry_step_deletion_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_random_time.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.punch_in_event_rule.arn
}