variable "aws_access_key" {}
variable "aws_secret_key" {}


builders {
  type          = "amazon-ebs"
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
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "ring-ring-ami{{timestamp}}"
  ami_description = "ring ring project"
  access_key    = var.aws_access_key
  secret_key    = var.aws_secret_key
}

provisioner "shell" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y docker.io",
    "sudo systemctl start docker",
    "sudo systemctl enable docker",
    "sudo usermod -aG docker ubuntu",
    "docker run -d -p 80:80 pavlopetrovua/node-for-rebiuld-lab:latest"
  ]
}
