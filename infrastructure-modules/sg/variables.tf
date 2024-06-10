#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "terraform-environment"
}

variable "vpc_id" {
  type = string
}