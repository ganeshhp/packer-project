{
  "builders": [
    {
      "boot_command": [
        "<esc><esc><enter><wait>",
        "/install/vmlinuz noapic ",
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
        "debian-installer=en_US auto locale=en_US kbd-chooser/method=us ",
        "hostname={{user `hostname`}} ",
        "fb=false debconf/frontend=noninteractive ",
        "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ",
        "keyboard-configuration/variant=USA console-setup/ask_detect=false ",
        "initrd=/install/initrd.gz -- <enter>"
      ],
      "disk_size": 10000,
      "guest_os_type": "Ubuntu_64",
      "http_directory": "http_directory",
      "http_port_max": 9001,
      "http_port_min": 9001,
      "iso_checksum": "md5:ac8a79a86a905ebdc3ef3f5dd16b7360",
      "iso_url": "https://releases.ubuntu.com/16.04/ubuntu-16.04.7-server-amd64.iso",
      "shutdown_command": "echo {{user `ssh_pass`}} | sudo -S shutdown -P now",
      "ssh_password": "{{user `ssh_pass`}}",
      "ssh_timeout": "20m",
      "ssh_username": "{{user `ssh_name`}}",
      "type": "virtualbox-iso",
      "vboxmanage": [
        [
          "modifyvm",
          "{{.Name}}",
          "--vram",
          "32"
        ]
      ]
    }
  ],
  "variables": {
    "hostname": "packer-vm",
    "ssh_name": "packer",
    "ssh_pass": "packer"
  }
}