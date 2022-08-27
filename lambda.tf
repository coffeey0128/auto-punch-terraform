module "lambda_random_time" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.0.0"

  function_name = "random-time"
  description   = "add random-time (0~600s) to delay punch"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  source_path = {
    path             = "${path.module}/resources/random-time"
    npm_requirements = true,
  }

  environment_variables = {
    SQS_PATH : module.sqs_punch_dalay.sqs_queue_id
  }
  tags = {
    Name = "lambda-random-time"
  }
}

module "lambda_auto_punch" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "4.0.0"

  function_name = "auto-punch"
  description   = "check work day > punch > send mail"
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  source_path = {
    path             = "${path.module}/resources/auto-punch"
    npm_requirements = true,
  }

  environment_variables = {
    SNS_PATH : aws_sns_topic.sns_punch_status.arn
    CID : var.cid_root_user
    PID : var.pid_root_user
    REFRESH_TOKEN : var.refresh_token_root_user
    DEVICE_ID : var.device_id_root_user
    LAT : var.lat
    LNG : var.lng
  }
  tags = {
    Name = "auto-punch"
  }
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = module.sqs_punch_dalay.sqs_queue_arn
  enabled          = true
  function_name    = module.lambda_auto_punch.lambda_function_name
}