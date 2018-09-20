module "alb" {
  # https://github.com/terraform-aws-modules/terraform-aws-alb for usage and list of outputs
  source  = "terraform-aws-modules/alb/aws"
  version = "3.4.0"

  logging_enabled     = true
  log_bucket_name     = "${aws_s3_bucket.log_bucket.id}"
  log_location_prefix = "${var.LOG_LOCATION_PREFIX}"

  load_balancer_name       = "my-alb"
  security_groups          = ["${module.alb-security-group.this_security_group_id}", "${module.web-security-group.this_security_group_id}"]
  subnets                  = ["${module.vpc.public_subnets}"]
  vpc_id                   = "${module.vpc.vpc_id}"
  http_tcp_listeners       = "${local.http_tcp_listeners}"
  http_tcp_listeners_count = "${local.http_tcp_listeners_count}"
  target_groups            = "${local.target_groups}"
  target_groups_count      = "${local.target_groups_count}"

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }
}
