locals {
  log_bucket_name = "${var.log_bucket_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"

  http_tcp_listeners_count = 1

  http_tcp_listeners = "${list(
                            map(
                                "port", 80,
                                "protocol", "HTTP",
                            ),
  )}"

  target_groups_count = 1

  target_groups = "${list(
                        map("name", "foo",
                            "backend_protocol", "HTTP",
                            "backend_port", 80,
                        ),
  )}"
}
