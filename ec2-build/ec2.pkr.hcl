
variable "ami_name" {
  type    = string
  default = "plusf-ami"
}
variable "hostname" {
    type = string
    default = "packer-vm"
}
variable "ssh_name" {  
    type = string
    ssh_name = "packer"
}
variable "ssh_pass" {
    type = "string"
    default = packer
}
variable "region" {
    default = "us-east-2"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "instance-1" {
#  access_key    = "${var.aws_access_key_id}"
  ami_name      = "packer-plus${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.region}"
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

source "virtualbox-iso" "test-vm" {
      boot_command = [
        "<esc><esc><enter><wait>",
        "/install/vmlinuz noapic ",
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
        "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
        "hostname={{var.hostname}}",
        "fb=false debconf/frontend=noninteractive ",
        "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
        "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
        "initrd=/install/initrd.gz -- <enter>"
      ]
     
      disk_size = 10000
      guest_os_type = Ubuntu_64
      http_directory = http_directory
      http_port_max = 9001
      http_port_min = 9001
      iso_checksum = "md5:ac8a79a86a905ebdc3ef3f5dd16b7360"
      iso_url = "https://releases.ubuntu.com/16.04/ubuntu-16.04.7-server-amd64.iso"
      shutdown_command = "echo ${local.ssh_pass} | sudo -S shutdown -P now"
      ssh_password = "${var.ssh_pass}"
      ssh_timeout = "20m"
      ssh_username = "${var.ssh_name}"
      type = "virtualbox-iso"
      vboxmanage = [
        [
          "modifyvm",
          "{{.Name}}",
          "--vram",
          "32"
        ]
      ]
}


# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.instance-1", "source.virtualbox-iso.test-vm"]

    provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt install software-properties-common",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible",
      ]
    }

#    provisioner "file" {
#      source = "./playbook.yml"
#      destination = "/tmp/playbook.yml"
#    }

    provisioner "ansible-local" {
      playbook_file   = "./playbook.yml"
    
    }
}

