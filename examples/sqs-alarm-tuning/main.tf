resource "aws_sqs_queue" "work" {
  name = "${var.product}-work"
}

module "service" {
  source = "../.."

  create_lb = false

  image_repo = "busybox"
  image_tag  = "latest"

  command = ["sleep", "infinity"]

  scaling_approach = "sqs"
  sqs_queue_name   = aws_sqs_queue.work.name
  min_capacity     = 0
  max_capacity     = 10

  # SQS can stop publishing metrics for a queue that has been idle for hours. Treat that as breaching the
  # scale-down alarm so an idle worker still scales down.
  sqs_down_evaluation_periods  = 3
  sqs_down_datapoints_to_alarm = 3
  sqs_down_treat_missing_data  = "breaching"

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
