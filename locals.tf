locals {
  log_bucket_name = "${var.LOG_BUCKET_NAME}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  http_tcp_listeners_count = 1

  http_tcp_listeners = "${list(
                            map(
                                "port", 80,
                                "protocol", "HTTP",
                            ),
  )}"

  azs = {
    us-east-1 = ["us-east-1a", "us-east-1b", "us-east-1c"]
    us-west-2 = ["us-west-2a", "us-west-2b", "us-west-2c"]
  }

  target_groups_count = 1

  target_groups = "${list(
                        map("name", "foo",
                            "backend_protocol", "HTTP",
                            "backend_port", 80,
                        ),
  )}"

}
