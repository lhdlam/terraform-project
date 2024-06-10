# AutoScalingGroup 
resource "aws_autoscaling_group" "auto_scaling_group" {
  name             = "my-autoscaling-group"
  desired_capacity = 2
  max_size         = 4
  min_size         = 2
  vpc_zone_identifier = flatten([
    var.public_subnet_ids,
  ])
  target_group_arns = [
    var.target_group_arn_id,
  ]
  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }
}

# Lookup Ubunut AMI Image
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

# Launch Template and ASG Resources
resource "aws_launch_template" "launch_template" {
  name          = "${var.environment}-launch-template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  network_interfaces {
    device_index    = 0
    security_groups = [var.asg_security_group_id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.environment}-asg-ec2"
    }
  }
  user_data = base64encode("${var.ec2_user_data}")
}
