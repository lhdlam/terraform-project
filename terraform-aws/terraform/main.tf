provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../infrastructure-modules/vpc"

  env             = "dev"
  azs             = ["us-east-1a","us-east-1b"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24"]
  public_subnets  = ["10.0.3.0/24","10.0.4.0/24"]

  private_subnet_tags = {
    "Name" = "private-subnet"
  }

  public_subnet_tags = {
    "Name" = "public-subnet"
  }
}

module "ec2" {
  source = "../../infrastructure-modules/ec2"
  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_id = module.vpc.vpc_id
  ssh_key_name = "new-key"
}
