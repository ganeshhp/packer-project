variable "ami_name" {
  type    = string
  default = "plusf-ami"
}
variable "region" {
  type	= string
  default = "us-east-2"
}
variable "region" {
  type  = string
  default = "us-east-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "image-build" {
#  access_key    = "${var.aws_access_key_id}"
#  secret_key    = "${var.aws_secret_access_key}"  
#  ami_name      = "packer-plus${local.timestamp}"  
  ami_name      = "${var.ami_name}"  
  instance_type = "t2.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}
build {
  sources = ["source.amazon-ebs.image-build"]
#    provisioner "shell" {
#    inline = [
#      "sudo apt-get update",
#      "sudo apt-get install software-properties-common -y",
#      "sudo apt-get install nginx -y",
#      "service nginx start",
#      ]
#    }
#    provisioner "file" {
#      source = "./playbook.yml"
#      destination = "/tmp/playbook.yml"
#    }
    provisioner "shell" {
      script = "./ansible.sh"
    }
    provisioner "ansible-local" {
      playbook_file   = "./playbook.yml"
    }
}
