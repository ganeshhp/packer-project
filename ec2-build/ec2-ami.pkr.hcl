variable "ami_name" {
  type    = string
  default = "plusf-ami"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "instance-1" {
#  access_key    = "${var.aws_access_key_id}"
  ami_name      = "packer-plus${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
#  secret_key    = "${var.aws_secret_access_key}"
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
  sources = ["source.amazon-ebs.instance-1"]
    provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install software-properties-common -y",
      "sudo apt-get install nginx -y",
      "service nginx start",
      ]
    }

  #  provisioner "file" {
  #    source = "./playbook.yml"
  #    destination = "/tmp/playbook.yml"
  #  }

  #  provisioner "ansible-local" {
  #    playbook_file   = "./playbook.yml"
  #  
  #  }
     
}