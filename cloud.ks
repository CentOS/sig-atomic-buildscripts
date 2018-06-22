text
lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC

auth --enableshadow --passalgo=sha512
selinux --enforcing
rootpw --lock --iscrypted locked
user --name=none

firewall --disabled

bootloader --timeout=1 --append="no_timer_check console=tty1 console=ttyS0,115200n8"

network --bootproto=dhcp --onboot=on
# We use NetworkManager, and Avahi doesn't make much sense in the cloud
services --disabled=network,avahi-daemon
services --enabled=NetworkManager,sshd,cloud-init,cloud-init-local,cloud-config,cloud-final

zerombr
clearpart --all

part /boot --size=300 --fstype="xfs"
part pv.01 --grow
volgroup atomicos pv.01
logvol / --size=3000 --fstype="xfs" --name=root --vgname=atomicos

# Equivalent of %include fedora-repo.ks
ostreesetup --osname="centos-atomic-host" --remote="centos-atomic-continuous" --ref="@OSTREE_REF@" --url="https://ci.centos.org/artifacts/sig-atomic/centos-continuous/ostree/repo/" --nogpg

reboot

%post --erroronfail
# Configure docker-storage-setup to resize the partition table on boot
# https://github.com/projectatomic/docker-storage-setup/pull/25
echo 'GROWPART=true' > /etc/sysconfig/docker-storage-setup

# Work around https://bugzilla.redhat.com/show_bug.cgi?id=1193590
cp /etc/skel/.bash* /var/roothome

# Anaconda is writing a /etc/resolv.conf from the generating environment.
# The system should start out with an empty file.
truncate -s 0 /etc/resolv.conf

# older versions of livecd-tools do not follow "rootpw --lock" line above
# https://bugzilla.redhat.com/show_bug.cgi?id=964299
passwd -l root
# remove the user anaconda forces us to make
userdel -r none

echo -n "Getty fixes"
# although we want console output going to the serial console, we don't
# actually have the opportunity to login there. FIX.
# we don't really need to auto-spawn _any_ gettys.
sed -i '/^#NAutoVTs=.*/ a\
NAutoVTs=0' /etc/systemd/logind.conf

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
PERSISTENT_DHCLIENT="yes"
EOF

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo .

# Because memory is scarce resource in most cloud/virt environments,
# and because this impedes forensics, we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount

# make sure firstboot doesn't start
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

echo "Removing random-seed so it's not the same in every image."
rm -f /var/lib/random-seed
%end

