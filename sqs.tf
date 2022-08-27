module "sqs_punch_dalay" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "3.3.0"

  name                      = "punch-queue"
  receive_wait_time_seconds = 20  // long pulling
}