locals {
  ssh_user = "ubuntu"
  key_name = "devops"
  instance_type = "t2.micro"
}

module "vpc" {
  source = "../../infrastructure-modules/vpc"

  env             = "ansible"
  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.0.0/26", "10.0.0.64/26"]
  public_subnets  = ["10.0.0.128/26", "10.0.0.192/26"]

  private_subnet_tags = {
    "Name" = "ansible-private-subnet"
  }

  public_subnet_tags = {
    "Name" = "ansible-public-subnet"
  }
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/ansible.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.ami.id
  instance_type          = local.instance_type
  vpc_security_group_ids = [aws_security_group.nginx.id]
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = module.vpc.public_subnet_ids[0]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install -y ansible"
    ]

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = tls_private_key.key.private_key_pem
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --key-file ansible.pem -T 300 -i '${self.public_ip}', playbook.yaml"
  }

  tags = {
    Name = "Web Server Ansible"
  }

}
