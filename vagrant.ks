# Like the Atomic Host cloud image, but tuned for vagrant: enable the
# vagrant user, disable cloud-init.

%include cloud.ks

user --name=vagrant --password=vagrant
rootpw vagrant

%post --erroronfail

# Really cloud-init should be disabled by default, and enabled
# only in the openstack qcow2 and AMI.
systemctl mask cloud-init cloud-init-local cloud-config cloud-final

# The inherited cloud %post locks the passwd, but we want it
# unlocked for vagrant, just like downstream.
passwd -u root

# Vagrant setup
sed -i 's/Defaults\s*requiretty/Defaults !requiretty/' /etc/sudoers
echo 'vagrant ALL=NOPASSWD: ALL' > /etc/sudoers.d/vagrant-nopasswd
sed -i 's/.*UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
mkdir -m 0700 -p ~vagrant/.ssh
cat > ~vagrant/.ssh/authorized_keys << EOKEYS
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOKEYS
chmod 600 ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh/


# Hack until we have https://github.com/rhinstaller/anaconda/issues/799
cd /root
curl -L -O https://kojipkgs.fedoraproject.org//packages/fuse-sshfs/2.5/1.el7/x86_64/fuse-sshfs-2.5-1.el7.x86_64.rpm
cat > /usr/local/bin/hack-vagrant-sshfs-install << EOF
#!/usr/bin/bash
set -xeuo pipefail
export HOME=/root
current=\$(ostree admin --print-current-dir)
sshfsrpm=\$(ls /root/fuse-sshfs*.rpm | head -1)
tmpd=\$(mktemp -d)
cd \${tmpd}
rpm2cpio < \${sshfsrpm} | cpio -div
mv ./usr/bin/sshfs \${current}/usr/bin/sshfs
rm \${tmpd} -rf
chcon -t bin_t \${current}/usr/bin/sshfs
mv \${current}/usr/share/rpm{,.orig}
cp -a \${current}/usr/share/rpm{.orig,}
rpm --ignoresize --dbpath=\${current}/usr/share/rpm --justdb -ivh \${sshfsrpm}
EOF
chmod a+x /usr/local/bin/hack-vagrant-sshfs-install
cat > /etc/systemd/system/hack-vagrant-sshfs-install.service << EOF
[Unit]
Description=Hack to install sshfs
Before=sshd.service
ConditionPathExists=!/usr/bin/sshfs

[Service]
Type=simple
ExecStart=/usr/local/bin/hack-vagrant-sshfs-install
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl enable hack-vagrant-sshfs-install

%end
