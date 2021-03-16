#!/bin/bash

sudo apt update
sudo apt install software-properties-common -y
sudo apt-add-repository -y --update ppa:ansible/ansible
sudo apt install ansible -y

