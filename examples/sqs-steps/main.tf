resource "aws_sqs_queue" "work" {
  name = "${var.product}-work"
}

module "service" {
  source = "../.."

  create_lb = false

  image_repo = "busybox"
  image_tag  = "latest"

  command = ["sleep", "infinity"]

  # Scale a worker on its queue depth, and add more tasks the bigger the backlog.
  scaling_approach         = "sqs"
  sqs_queue_name           = aws_sqs_queue.work.name
  sqs_visible_up_threshold = 100
  min_capacity             = 1
  max_capacity             = 10

  # Bounds are offsets from the threshold, in messages: 100-200 visible adds 1 task, 200-600 adds 3, and above 600 adds 6.
  scale_up_steps = [
    { lower_bound = 0, upper_bound = 100, adjustment = 1 },
    { lower_bound = 100, upper_bound = 500, adjustment = 3 },
    { lower_bound = 500, adjustment = 6 },
  ]

  organization = var.organization
  environment  = var.environment
  product      = var.product
  owner        = var.owner
  repo         = var.repo
}
