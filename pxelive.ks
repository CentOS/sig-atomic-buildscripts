# PXE-to-Live Atomic: PXE boot directly into a running Atomic Host

lang en_US.UTF-8
keyboard us
timezone America/New_York
zerombr
clearpart --all --initlabel
rootpw --lock --iscrypted locked
user --name=none
bootloader --timeout=1
network --bootproto=dhcp --device=link --activate
part / --fstype="xfs" --size=6000
# ostree only does separate /boot partition currently
part /boot --size=200 --fstype="xfs"
shutdown
services --disabled=docker-storage-setup,network
services --enabled=NetworkManager,sshd,cloud-init,cloud-init-local,cloud-config,cloud-final
 
ostreesetup --osname="centos-atomic-host" --remote="centos-atomic-host" --ref="centos-atomic-host/7/x86_64/standard" --url="http://192.168.122.1:8000/repo/" --nogpg
 
%post

# Ensure the root password is locked, we use cloud-init
passwd -l root
userdel -r none

# We copy content of separate /boot partition to root part when building live squashfs image,
# and we don't want systemd to try to mount it when pxe booting
cat /dev/null > /etc/fstab
%end
