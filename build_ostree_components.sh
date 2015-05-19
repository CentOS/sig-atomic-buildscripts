#!/bin/bash


## Run the script from /srv (or other HomeDir, if you change the value
## below) like so:
##
## bash sig-atomic-buildscripts/build_ostree_components.sh /srv/builddir
## 
## Other files to edit/check:
##
## atomic-7.1.tdl must point to an install tree avail over http,
## there's a hard-coded IP address there now
## 
## atomic-7.1-cloud.ks and atomic-7.1-vagrant.ks must point to
## the desired ostree repo in line beginning w/ "ostreesetup"


HomeDir=$(pwd)
DateStamp=$( date  +%Y%m%d_%H%M%S )
BuildDir=$1
LogFile=${BuildDir}/log
mkdir -p ${BuildDir}
# Make it absolute
BuildDir=$(cd $BuildDir && pwd)

# this is a bit of a hack, we need a better way ( or a fixed place
# to always expect the GitDir, ideally under BuildDir
if [ -e ${HomeDir}/centos-atomic-host.json ]; then
  GitDir=${HomeDir}
else
  GitDir=${HomeDir}/sig-atomic-buildscripts
fi

set -x
set -e
set -o pipefail

# Init, make sure we have the bits we need installed. 
cp -f ${GitDir}/rhel-atomic-rebuild.repo /etc/yum.repos.d/
yum -y install ostree rpm-ostree docker libvirt epel-release

cp -f ${GitDir}/atomic7-testing.repo /etc/yum.repos.d/
echo 'enabled=0' >> /etc/yum.repos.d/atomic7-testing.repo
yum --enablerepo=atomic7-testing -y install rpm-ostree-toolbox

service firewalld stop
service iptables stop

## update script from git, commented out for now

#test -d ${GitDir} || git clone https://github.com/CentOS/sig-atomic-buildscripts
#cd ${GitDir}; git clean -dfx; git reset --hard origin/downstream; git pull -r

## backup the last built repo, commented out for now

#  XXX: We need to only retain the last 14 builds or so, Todo, add a find + rm for older tree's
#/bin/rsync -Ha --stats /srv/rolling/ /srv/rolling.${DateStamp} > ${LogFile} 2>&1
#echo '----------' >> ${LogFile}

## create repo in HomeDir, this will fail w/o issue if already exists

if ! test -d ${HomeDir}/repo/objects; then
    ostree --repo=${HomeDir}/repo init --mode=archive-z2
fi

## compose a new tree, based on defs in centos-atomic-host.json

rpm-ostree compose --repo=${HomeDir}/repo/ tree ${GitDir}/centos-atomic-host.json |& tee ${BuildDir}/log.compose

## tree-signing, commented out for now

#if [ $? -eq '0' ]; then
  # now we sign it
#  ostree --repo=/srv/rolling gpg-sign centos/7/atomic/x86_64/cloud-docker-host 0xA866D7CCAE087291 >> ${LogFile} 
#  echo '----------' >> ${LogFile}

## rsync tree to a more permanent home, commented out for now

#  if [ $? -eq 0 ]; then 
#    /bin/rsync -PHa --stats /srv/rolling/* pushhost::c7-atomic/x86_64/repo/ >> ${LogFile}  2>&1
#    echo '----------' >> ${LogFile}
#  fi
#fi

## docker and libvirt need to be running

systemctl start docker
systemctl start libvirtd

## This part creates an install tree and install iso 

echo '---------- installer ' >> ${LogFile}
rpm-ostree-toolbox installer --overwrite --ostreerepo ${HomeDir}/repo -c  ${GitDir}/config.ini -o ${BuildDir}/installer |& tee ${LogFile}

# we likely need to push the installer content to somewhere the following kickstart
#  can pick the content from ( does it otherwise work with a file:/// url ? unlikely )
python -m SimpleHTTPServer 8000 &

echo '---------- Vagrant ' >> ${LogFile}
rpm-ostree-toolbox imagefactory --overwrite --tdl ${GitDir}/atomic-7.1.tdl -c  ${GitDir}/config.ini -i kvm -i vagrant-libvirt -i vagrant-virtualbox -k ${GitDir}/atomic-7.1-cloud.ks --vkickstart ${GitDir}/atomic-7.1-vagrant.ks -o ${BuildDir}/virt |& tee ${LogFile}


## Make a place to copy finished images

mkdir -p ${HomeDir}/images/
cp -r ${BuildDir}/virt/* ${HomeDir}/images/
cp ${HomeDir}/builddir/installer/images/images/installer.iso ${HomeDir}/images/centos-atomic-host-7.iso
rm -rf ${BuildDir}/virt

# TODO we need a liveimage ks for this part

#echo '---------- liveimage ' >> ${LogFile}
#rpm-ostree-toolbox liveimage -c  ${GitDir}/config.ini -o pxe-to-live >> ${LogFile} 2>&1
echo '----------' >> ${LogFile}

#/bin/rsync -PHvar ${BuildDir} pushhost::c7-atomic/x86_64/Builds/ >> ${LogFile}  2>&1

