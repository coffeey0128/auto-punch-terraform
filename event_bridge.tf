// Punch in -------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "punch_in_event_rule" {
  name                = "auto-punch-in"
  description         = "Trigger random punch time at 10:00 +0800 "
  schedule_expression = "cron(00 2 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "punch_in_event_rule_target" {
  arn  = module.lambda_random_time.lambda_function_arn
  rule = aws_cloudwatch_event_rule.punch_in_event_rule.name
}
 
resource "aws_lambda_permission" "allow_punch_in_cloudwatch_to_call_rw_fallout_retry_step_deletion_lambda" {
  statement_id  = "AllowExecutionFromAutoPunchIn"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_random_time.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.punch_in_event_rule.arn
}

// Punch out -------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "punch_out_event_rule" {
  name                = "auto-punch-out"
  description         = "Trigger random punch time at 18:15 +0800 "
  schedule_expression = "cron(15 10 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "punch_out_event_rule_target" {
  arn  = module.lambda_random_time.lambda_function_arn
  rule = aws_cloudwatch_event_rule.punch_out_event_rule.name
}

resource "aws_lambda_permission" "allow_punch_out_cloudwatch_to_call_rw_fallout_retry_step_deletion_lambda" {
  statement_id  = "AllowExecutionFromAutoPunchOut"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_random_time.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.punch_out_event_rule.arn
}
