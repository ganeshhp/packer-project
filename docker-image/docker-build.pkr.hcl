variable "password" {
        default = "replace_with_password"
}
variable "username" {
	default = "replace_with_username"
}
variable "repo1" {
	default = "ganeshhp/ubuntu"
}
variable "repo1-tag" {
        default = "16.04"
}
variable "repo2" {
	default = "ganeshhp/centos"
}
variable "repo2-tag" {
	default = "latest"
}

source "docker" "ubuntu_custom" {
    image = "ubuntu:xenial"
    changes = [
      "USER www-data",
      "WORKDIR /var/www",
      "ENV HOSTNAME www.plusforum.in",
      "VOLUME /test1 /test2",
      "EXPOSE 80 443",
      "LABEL version=1.0",
      "ONBUILD RUN apt-get install apache2 -y",
      "CMD [\"nginx\", \"-g\", \"daemon off;\"]",
      "ENTRYPOINT /var/www/start.sh"
     ]
    export_path = "./ubuntu-custom.tar"
}

source "docker" "centos_custom" {
    image = "centos:latest"
    changes = [
      "USER www-data",
      "WORKDIR /var/www",
      "ENV HOSTNAME www.plusforum.in",
      "VOLUME /test1 /test2",
      "EXPOSE 80 443",
      "LABEL version=1.0",
      "ONBUILD RUN yum install httpd -y",
      "CMD [\"httpd\", \"-g\", \"daemon off;\"]",
      "ENTRYPOINT /var/www/start.sh"
     ]
    export_path = "./centos-custom.tar"
}

build {
  sources = ["source.docker.ubuntu_custom", "source.docker.centos_custom"]
 
  provisioner "shell" {
    script = "ansible-ubuntu.sh"
    only = ["docker.ubuntu_custom"] 
  }

  provisioner "shell" {
    script = "ansible-centos.sh"
    only = ["docker.centos_custom"]
  } 

  provisioner "ansible-local" {
    playbook_file = "common.yaml"
  }


  post-processors {

    post-processor "docker-push" {
        login = true
        login_username = "${var.username}"
        login_password = "${var.password}"
      }

    post-processor "docker-import" {
        repository =  "${var.repo1}"
        tag = "${var.repo1-tag}"
        only = ["docker.ubuntu_custom"]
      }
    post-processor "docker-import" {
        repository =  "${var.repo2}"
        tag = "${var.repo2-tag}"
        only = ["docker.centos_custom"]
      }
  }
}
