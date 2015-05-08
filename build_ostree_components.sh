#!/bin/bash

HomeDir=/srv
DateStamp=$( date  +%Y%m%d_%H%M%S )
BuildDir=$1
LogFile=${BuildDir}/log
mkdir -p ${BuildDir}
GitDir=${HomeDir}/sig-atomic-buildscripts/

cd $HomeDir
#test -d ${GitDir} || git clone https://github.com/CentOS/sig-atomic-buildscripts
#cd ${GitDir}; git clean -dfx; git reset --hard origin/downstream; git pull -r

# backup the last built repo
#  XXX: We need to only retain the last 14 builds or so, Todo, add a find + rm for older tree's
#/bin/rsync -Ha --stats /srv/rolling/ /srv/rolling.${DateStamp} > ${LogFile} 2>&1
#echo '----------' >> ${LogFile}

# create repo

# ostree --repo=/srv/rolling init --mode=archive-z2

# build a new one

#rpm-ostree compose --repo=/srv/rolling/ tree ${GitDir}/centos-atomic-host.json > ${BuildDir}/log.compose 2>&1
#if [ $? -eq '0' ]; then
  # now we sign it
#  ostree --repo=/srv/rolling gpg-sign centos/7/atomic/x86_64/cloud-docker-host 0xA866D7CCAE087291 >> ${LogFile} 
#  echo '----------' >> ${LogFile}
#  if [ $? -eq 0 ]; then 
#    /bin/rsync -PHa --stats /srv/rolling/* pushhost::c7-atomic/x86_64/repo/ >> ${LogFile}  2>&1
#    echo '----------' >> ${LogFile}
#  fi
#fi

# the installer output dir referenced below must be made to exist

mkdir -p ${HomeDir}/installer/

# docker needs to be running

systemctl start docker

cd ${BuildDir}
echo '---------- installer ' >> ${LogFile}
#rpm-ostree-toolbox installer -c  ${GitDir}/config.ini -o ${HomeDir}/installer >> ${LogFile} 2>&1
rpm-ostree-toolbox installer --ostreerepo ${HomeDir}/rolling/ -c  ${GitDir}/config.ini -o ${HomeDir}/installer >> ${LogFile} 2>&1
# we likely need to push the installer content to somewhere the following kickstart
#  can pick the content from ( does it otherwise work with a file:/// url ? unlikely )
echo '---------- Vagrant ' >> ${LogFile}
rpm-ostree-toolbox imagefactory --tdl ${GitDir}/atomic-7.1.tdl -i kvm -i vagrant-libvirt -i vagrant-virtualbox -k ${GitDir}/atomic-7.1-cloud.ks --vkickstart ${GitDir}/atomic-7.1-vagrant.ks -o virt >> ${LogFile}  2>&1
echo '---------- liveimage ' >> ${LogFile}
rpm-ostree-toolbox liveimage -o pxe-to-live >> ${LogFile} 2>&1 
echo '----------' >> ${LogFile}

#/bin/rsync -PHvar ${BuildDir} pushhost::c7-atomic/x86_64/Builds/ >> ${LogFile}  2>&1

