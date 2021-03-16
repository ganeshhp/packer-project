
#data "amazon-ami" "example" {
#  filters = {
#    virtualization-type = "hvm"
#    name                = "*Windows_Server-2012*English-64Bit-Base*"
#    root-device-type    = "ebs"
#  }
#  owners      = ["amazon"]
#  most_recent = true
#  # Access Region Configuration
#  region      = "us-east-1"
#}
# This example uses a amazon-ami data source rather than a specific AMI.
# this allows us to use the same filter regardless of what region we're in,
# among other benefits.
source "amazon-ebs" "winrm-example" {
  region =  "us-east-2"
#  source_ami = data.amazon-ami.example.id
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "*Windows_Server-2012*English-64Bit-Base*"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
    # Access Region Configuration
    
} 
  instance_type =  "t2.small"
  ami_name =  "packer_winrm_example {{timestamp}}"
  # This user data file sets up winrm and configures it so that the connection
  # from Packer is allowed. Without this file being set, Packer will not
  # connect to the instance.
  user_data_file = "./bootstrap.txt"
  communicator = "winrm"
  force_deregister = true
  winrm_insecure = true
  winrm_username = "Administrator"
  winrm_use_ssl = true
}

build {
  sources = [
    "source.amazon-ebs.winrm-example"
  ]
 
  provisioner "windows-restart" {
  }
 
  provisioner "powershell" {
    inline = [
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/InitializeInstance.ps1 -Schedule",
      "C:/ProgramData/Amazon/EC2-Windows/Launch/Scripts/SysprepInstance.ps1 -NoShutdown"
    ]
  }
}