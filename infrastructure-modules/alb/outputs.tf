output "target_group_arns" {
  value = aws_lb_target_group.target_group.arn
}

output "alb_public_url" {
  description = "Public URL for Application Load Balancer"
  value       = aws_lb.alb.dns_name
}