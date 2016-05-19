#!/bin/bash
# Karanbir Singh feb 2016
# this script assumes its being run on CentOS Linux 7/x86_64

yum -y install centos-release-scl
yum -y install wget curl rsync sclo-vagrant1 sclo-vagrant1-vagrant-libvirt libvirt qemu-kvm
service libvirtd status
if [ $? -ne 0 ]; then
  service libvirtd start
fi

chmod u+x tests/vagrant-test.sh
scl enable sclo-vagrant1 ./tests/vagrant-test.sh
