provider "aws" {
  region = "us-east-1"  # Замініть на свою регіон AWS
}

terraform {
  backend "s3" {
    bucket         = "petrov-pavlo-2023-11-20"
    key            = "aws/main/build_temp_instance/terraform.tfstate"
    region         = "us-east-1"  
    encrypt        = true
  }
}

data "terraform_remote_state" "main_line" {
  backend = "s3"
  config = {
    bucket = "petrov-pavlo-2023-11-20"
    key    = "aws/main/terraform.tfstate"
    region = "us-east-1"
  }
}

#data "github_actions_secret" "private_key" {
#  name = "EC2_GITHUB"
#}


resource "aws_instance" "ami_ring_ring" {
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.main_line.outputs.subnet_ids[1]
  key_name      = "ec2_github"
  vpc_security_group_ids = [data.terraform_remote_state.main_line.outputs.security_group_id]
  associate_public_ip_address = true
 
  tags = {
    Name = "example-instance"
  }

  provisioner "remote-exec" {
  inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = base64decode(secrets.SSH_PRIVATE_KEY)
 #     private_key = file"${TF_VAR_secret_key}"
 #     private_key = data.github_actions_secret.private_key.name
      host        = aws_instance.ami_ring_ring.public_ip
     }
   }

#  provisioner "local-exec" {
#    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
#  }
}







