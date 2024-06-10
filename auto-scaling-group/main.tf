module "vpc" {
  source = "../infrastructure-modules/vpc"

  env             = "dev"
  azs             = ["us-east-1a","us-east-1b"]
  private_subnets = ["10.0.0.0/26","10.0.0.64/26"]
  public_subnets  = ["10.0.0.128/26","10.0.0.192/26"]

  private_subnet_tags = {
    "Name" = "private-subnet"
  }

  public_subnet_tags = {
    "Name" = "public-subnet"
  }
}

# Security Group Resources
module "sg" {
  source = "../infrastructure-modules/sg"
  vpc_id = module.vpc.vpc_id
}

# Application Load Balancer Resources
module "alb" {
  source = "../infrastructure-modules/alb"
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_security_group_id = module.sg.alb_security_group_id
}

# AutoScalingGroup 
module "asg" {
  source = "../infrastructure-modules/asg"
  target_group_arn_id = module.alb.target_group_arns
  public_subnet_ids = module.vpc.public_subnet_ids
  asg_security_group_id = module.sg.asg_security_group_id
}