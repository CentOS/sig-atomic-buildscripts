#!/bin/bash
if [ -e Vagrantfile ]; then rm Vagrantfile ; fi
vagrant box add --name testbox  /srv/images/centos-atomic-host-7-vagrant-libvirt.box
vagrant init testbox
vagrant up --provider libvirt
vagrant ssh -c "uname -r"
if [ $? -ne 0 ]; then
  echo 'XX: FAIL: vagrant filed to bring up box'
  exit 1
fi
vagrant ssh -c "sudo docker run centos"
if [ $? -ne 0 ]; then
  echo 'XX: FAIL: atomic host box failed to run centos container'
  exit 1
fi
exit 0

