output "asg_security_group_id" {
  value = aws_security_group.asg_security_group.id
  description = "ASG Security Group"
}

output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
  description = "ALB Security Group"
}