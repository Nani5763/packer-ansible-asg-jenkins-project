packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.0.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

source "amazon-ebs" "ubuntu" {
  region           = var.aws_region
  instance_type    = "t2.micro"
  ami_name         = "ansible-ami-{{timestamp}}"
  ssh_username     = "ubuntu"
  # key_pair_name        = "Ansible+Packer-Manual-Process-key"
  # ssh_private_key_file = "C:/Users/pavan/.ssh/Ansible+Packer-Manual-Process-key.pem"



  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"]  # Canonical Ubuntu
    most_recent = true
  }
}

build {
  name    = "build-ami"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    playbook_file = "ansible/playbook.yml"
  }
}
