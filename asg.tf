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
  user_data = "#!/bin/bash\nsudo yum update -y && sudo yum install -y docker && sudo usermod -aG docker ec2-user && sudo service docker start && docker run -d -p 80:80 nginx"
}
