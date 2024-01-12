# packer.pkr.hcl

variable "aws_access_key" {}
variable "aws_secret_key" {}

source "amazon-ebs" "ring-ring" {
  ami_name      = "ubuntu-with-docker-and-node"
  instance_type = "t2.micro"
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
}

build {
  sources = ["source.amazon-ebs.ring-ring"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "docker run -d -p 80:80 pavlopetrovua/node-for-rebuild-lab:latest"
    ]
  }

  post-processors {
    amazon-ami = {
      access_key    = var.aws_access_key
      secret_key    = var.aws_secret_key
      region        = "us-east-1"
      source_ami    = "{{.Build.Sources.amazon-ebs.ring-ring.AMI}}"
      ami_name      = "ubuntu-with-docker-and-node-{{timestamp}}"
      snapshot_tags = {
        Name = "ubuntu-with-docker-and-node"
      }
    }
  }

  provisioner "shell" {
    inline = [
        "echo $AMI_ID > ami_id.txt"
  ]
}
}