#!/bin/sh

ksflatten -c centos-atomic-host-7-vagrant.ks -o centos-atomic-host-7-vagrant-flat.ks

koji -p cbs image-build \
  centos-7-atomic-scratch 1 atomic7-el7.centos \
  http://buildlogs.centos.org/centos/7/atomic/x86_64/atomic-anaconda-nightly/latest/ x86_64 \
  --release=1 \
  --distro RHEL-7.0 \
  --ksver RHEL7 \
  --kickstart=./centos-atomic-host-7-vagrant-flat.ks \
  --format=qcow2 \
  --format=vsphere-ova \
  --format=rhevm-ova \
  --ova-option vsphere_ova_format=vagrant-virtualbox \
  --ova-option rhevm_ova_format=vagrant-libvirt \
  --ova-option vagrant_sync_directory=/home/vagrant/sync \
  --scratch \
  --nowait \
  --disk-size=10

