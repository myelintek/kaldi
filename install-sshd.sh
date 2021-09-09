#!/bin/bash

apt-get install -y openssh-server

# ssh server setup
mkdir /var/run/sshd && \
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
sed -i -e "s/#AuthorizedKeysFile.*/AuthorizedKeysFile \/root\/.ssh\/authorized_keys/g" /etc/ssh/sshd_config && \
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
