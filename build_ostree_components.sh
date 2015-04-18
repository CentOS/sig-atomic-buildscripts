#!/bin/bash

HomeDir=/srv
DateStamp=$( date  +%Y%m%d_%H%M%S )
BuildDir=$1
LogFile=${BuildDir}/log
mkdir -p ${BuildDir}
GitDir=${HomeDir}/sig-atomic-buildscripts/

cd $HomeDir
test -d ${GitDir} || git clone https://github.com/CentOS/sig-atomic-buildscripts
cd ${GitDir}; git clean -dfx; git reset --hard origin/master; git pull -r

# backup the last built repo
#  XXX: We need to only retain the last 14 builds or so, Todo, add a find + rm for older tree's
/bin/rsync -Ha --stats /srv/rolling/ /srv/rolling.${DateStamp} > ${LogFile} 2>&1
echo '----------' >> ${LogFile}

# build a new one

rpm-ostree compose --repo=/srv/rolling/ tree centos-atomic-host.json > ${BuildDir}/log.compose 2>&1
if [ $? -eq '0' ]; then
  /bin/rsync -PHa --stats /srv/rolling/* pushhost::c7-atomic/x86_64/repo/ >> ${LogFile}  2>&1
  echo '----------' >> ${LogFile}
fi


cd ${BuildDir}
echo '---------- installer ' >> ${LogFile}
rpm-ostree-toolbox installer -c  ${GitDir}/installer.ini -o installer >> ${LogFile} 2>&1
# we likely need to push the installer content to somewhere the following kickstart
#  can pick the content from ( does it otherwise work with a file:/// url ? unlikely )
echo '---------- Vagrant ' >> ${LogFile}
rpm-ostree-toolbox imagefactory -i kvm -i vagrant-libvirt -i vagrant-virtualbox -k ${GitDir}/centos-atomic-host-7.ks --vkickstart ${GitDir}/centos-atomic-host-7-vagrant.ks -o virt >> ${LogFile}  2>&1
echo '---------- liveimage ' >> ${LogFile}
rpm-ostree-toolbox liveimage -o pxe-to-live >> ${LogFile} 2>&1 
echo '----------' >> ${LogFile}

/bin/rsync -PHvar ${BuildDir} pushhost::c7-atomic/x86_64/Builds/ >> ${LogFile}  2>&1

