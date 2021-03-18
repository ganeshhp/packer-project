variable "password" {
        default = "replace_with_password"
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
        login_username = "ganeshhp"
        login_password = "${var.password}"
      }

    post-processor "docker-import" {
        repository =  "ganeshhp/ubuntu-custom"
        tag = "16.04"
        only = ["docker.ubuntu_custom"]
      }
    post-processor "docker-import" {
        repository =  "ganeshhp/centos-custom"
        tag = "latest"
        only = ["docker.centos_custom"]
      }
  }
}
