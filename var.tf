variable ENVIRONMENT {}
variable AWS_PROFILE {}

variable AWS_REGION {
  default = "us-west-2"
}

# Amazon Linux 2
variable EXAMPLE_ASG_AMIS {
  type = "map"

  default = {
    us-west-1 = "ami-0782017a917e973e7"
    us-west-2 = "ami-6cd6f714"
  }
}

variable EC2_INSTANCE_SIZE {}

variable "log_bucket_name" {
  default = "nn-test-log-bucket"
}

variable "log_location_prefix" {
  default = "my-lb-logs"
}
