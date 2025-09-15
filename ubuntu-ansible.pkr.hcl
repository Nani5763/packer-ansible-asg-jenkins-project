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
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  region           = var.aws_region
  instance_type    = "t2.micro"
  ami_name         = "ansible-ami-{{timestamp}}"
  ssh_username     = "ubuntu"  

  # If you want to use your own key instead of Packer’s temporary one, uncomment:
  # ssh_keypair_name     = "mykeytest"
  # ssh_private_key_file = "C:\\Users\\pavan\\.ssh\\mykeytest.pem"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical
    most_recent = true
  }
}

build {
  name    = "build-ami"
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "ansible" {
    playbook_file   = "ansible/playbook.yml"
    user            = "ubuntu"  # Ensures Ansible uses correct SSH user
    extra_arguments = [
      "--become",                                # Allow privilege escalation
      "--ssh-extra-args='-o StrictHostKeyChecking=no'"
    ]
  }
}
