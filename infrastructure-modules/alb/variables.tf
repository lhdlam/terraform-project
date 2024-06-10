#This is a Environement variable 
variable "environment" {
  description = "Environment name for deployment"
  type        = string
  default     = "terraform-environment"
}


variable "public_subnet_ids" {
  type        = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}