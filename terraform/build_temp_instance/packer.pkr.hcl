# packer.pkr.hcl

variable "aws_access_key" {}
variable "aws_secret_key" {}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ring-ring" {
  ami_name      = "ubuntu-with-docker-and-node"
  instance_type = "t3.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ring-ring"]


provisioner "shell" {
  inline = [
    "sudo apt update -y",
    "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg",
    "sudo install -m 0755 -d /etc/apt/keyrings",
    "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
    "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
    "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
    "sudo apt update -y",
    "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
    //"sudo groupadd docker",
    "sudo usermod -aG docker $USER",
    "newgrp docker",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",
    "sudo docker run hello-world",
    "sudo docker pull pavlopetrovua/node-for-rebiuld-lab",
    "sudo docker run -d -p 9007:9007 --rm pavlopetrovua/node-for-rebiuld-lab:latest"
  ]
}



  // post-processors {
  //   amazon-ami = {
  //     access_key    = var.aws_access_key
  //     secret_key    = var.aws_secret_key
  //     region        = "us-east-1"
  //     source_ami    = "{{.Build.Sources.amazon-ebs.ring-ring.AMI}}"
  //     ami_name      = "ubuntu-with-docker-and-node-{{timestamp}}"
  //     snapshot_tags = {
  //       Name = "ubuntu-with-docker-and-node"
  //     }
  //   }
  // }

  provisioner "shell" {
    inline = [
        "echo $AMI_ID > ami_id.txt"
    ]
  }
}
