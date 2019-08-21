FROM hashicorp/packer:1.4.3

MAINTAINER Jürgen Löhel "<juergen@loehel.de"

RUN set -eux; \
     apk update ; \
     apk add --no-cache \
         qemu-system-x86_64 \
         libvirt \
         qemu-img \
         ; \
     wget https://github.com/tcnksm/ghr/releases/download/v0.12.0/ghr_v0.12.0_linux_amd64.tar.gz && tar xf ghr_* --strip-components=1 -C /usr/bin
