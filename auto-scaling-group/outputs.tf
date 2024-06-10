output "alb_public_url" {
  description = "Public URL for Application Load Balancer"
  value       = module.alb.alb_public_url
}