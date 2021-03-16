#!/bin/bash -e
apt-get install -y linux-headers-$(uname -r) build-essential dkms

cd /tmp
mkdir /tmp/isomount 
mount -t iso9660 -o loop /home/packer/VBoxGuestAdditions.iso /tmp/isomount

# install the drivers

/tmp/isomount/VBoxLinuxAdditions.run

#cleanup

umount isomount
rm -rf isomount /home/packer/VBoxGuestAdditions.iso