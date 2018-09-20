module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.44.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "2.8.0"

  name = "example-service"

  # Launch configuration
  lc_name = "example-lc"

  image_id        = "${lookup(var.EXAMPLE_ASG_AMIS, var.AWS_REGION)}"
  instance_type   = "${var.EC2_INSTANCE_SIZE}"
  security_groups = ["${module.instance-security-group.this_security_group_id}"]
  key_name        = "${aws_key_pair.tf_key.key_name}"

  ebs_block_device = [
    {
      device_name           = "/dev/xvdz"
      volume_type           = "gp2"
      volume_size           = "50"
      delete_on_termination = true
    },
  ]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  target_group_arns = ["${module.alb.target_group_arns}"]

  # Auto scaling group
  asg_name                  = "example-asg"
  vpc_zone_identifier       = ["${module.vpc.private_subnets}"] #this is where Terraform gets REAAALLLY powerful
  health_check_type         = "EC2"
  min_size                  = 3
  max_size                  = 10
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${var.ENVIRONMENT}"
      propagate_at_launch = true
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]

  # installs Docker and echo image to demonstrate LB in multi-AZ
  user_data = "#!/bin/bash\nsudo yum update -y && sudo yum install -y docker && sudo usermod -aG docker ec2-user && docker run -d -p 80:3333 n0r1skcom/echo"
}

module "web-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.5.0"

  name        = "WebOpen"
  description = "Allows all traffic to HTTP port"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP Ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "All ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }
}

module "alb-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.5.0"
  name    = "ALB"

  name        = "ALB-${var.ENVIRONMENT}"
  description = "Apply to Application Load Balancer"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }
}

module "instance-security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.5.0"

  name        = "WebOpenFromALB-${var.ENVIRONMENT}"
  description = "Allows all traffic from ALB security group to HTTP port"
  vpc_id      = "${module.vpc.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      source_security_group_id = "${module.alb-security-group.this_security_group_id}"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "All ports"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${local.log_bucket_name}"
  policy        = "${data.aws_iam_policy_document.bucket_policy.json}"
  force_destroy = true

  tags = {
    Terraform   = "true"
    Environment = "${var.ENVIRONMENT}"
  }

  lifecycle_rule {
    id      = "log-expiration"
    enabled = "true"

    expiration {
      days = "7"
    }
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.4.0"

  logging_enabled     = true
  log_bucket_name     = "${aws_s3_bucket.log_bucket.id}"
  log_location_prefix = "${var.log_location_prefix}"

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

resource "aws_key_pair" "tf_key" {
  key_name   = "tf_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCcn+Npk0DRwKzfZAclNuE/MtHAeThvLgF+yuCIPTN/rWAXf1hlEWJNvKCR7b2ua2+ZoodvS48mC4w+9xpllkvp6eNCRhASCGr11+3gfuFmXOH2IF2yDculcfQ2l/qu3rPTZhGd8VhyUzZ7L67dZGIOu4QUGVCe2NKNDE5eiWeBZYu4pTKwV8dz/gFNP9gWF98VM2OMmhYVRqOsesv8ovInNhSKhUB4rV7GtZag2Z0IjFYEzoYw2o+TFNLYmLoezM4WMk74m10CJKxi9Ij1EdFy1zWSgl6xMk4oY9jUlz0Jgc5uBhNfLgjKGYfxWDVta5TQ3P7gU4Xe3eDKHU/esg4R tf_key"
}
