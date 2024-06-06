provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../infrastructure-modules/vpc"

  env             = "dev"
  azs             = ["us-east-1a"]
  private_subnets = ["10.0.0.0/19"]
  public_subnets  = ["10.0.32.0/19"]

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
