resource "aws_route53_record" "tf" {
  zone_id = "Z2EYP36A0DISOC" # this is static for the sake of example
  name    = "tf.policycat.com"
  type    = "A"

  alias {
    name                   = "${module.alb.dns_name}"
    zone_id                = "Z1H1FL5HABSF5"
    evaluate_target_health = true
  }
}
