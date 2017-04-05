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

VERSION=7.$( date  +%Y%m%d )

DateStamp=$( date  +%Y%m%d_%H%M%S )
BuildDir=$1
LogFile=${BuildDir}/log
mkdir -p ${BuildDir}
# Make it absolute
BuildDir=$(cd $BuildDir && pwd)
GitDir=${BuildDir}/sig-atomic-buildscripts
OstreeRepoDir=/srv/repo && mkdir -p $OstreeRepoDir
ln -s ${OstreeRepoDir} ${BuildDir}/repo

set -x
set -e
set -o pipefail

## update script from git, commented out for now
cd ${BuildDir}
git clone https://github.com/CentOS/sig-atomic-buildscripts && cd sig-atomic-buildscripts && git checkout downstream
cd ${BuildDir}

# Init, make sure we have the bits we need installed. 
cp -f ${GitDir}/rhel-atomic-rebuild.repo /etc/yum.repos.d/
yum -y install ostree rpm-ostree glib2 docker libvirt epel-release libgsystem

cp -f ${GitDir}/atomic7-testing.repo /etc/yum.repos.d/
echo 'enabled=0' >> /etc/yum.repos.d/atomic7-testing.repo
yum --enablerepo=atomic7-testing -y install rpm-ostree-toolbox

service firewalld stop


## backup the last built repo, commented out for now

#  XXX: We need to only retain the last 14 builds or so, Todo, add a find + rm for older tree's
#/bin/rsync -Ha --stats /srv/rolling/ /srv/rolling.${DateStamp} > ${LogFile} 2>&1
#echo '----------' >> ${LogFile}

## create repo in BuildDir, this will fail w/o issue if already exists

if ! test -d ${BuildDir}/repo/objects; then
    ostree --repo=${BuildDir}/repo init --mode=archive-z2
fi

# sync repo from ds location

ostree remote add --repo=/srv/repo centos-atomic-host --set=gpg-verify=false http://mirror.centos.org/centos/7/atomic/x86_64/repo && ostree pull --depth=-1 --repo=/srv/repo --mirror centos-atomic-host centos-atomic-host/7/x86_64/standard

# temp fix for issue 259

ostree --repo=/srv/repo static-delta generate --from d433342b09673c9c4d75ff6eef50a447e73a7541491e5197e1dde14147b164b8 --to 841fae51e5b68716a9996ddbdb4e543855bbfab9c6e4cb433267b24e41e8bbc1 && ostree --repo=/srv/repo summary -u

## compose a new tree, based on defs in centos-atomic-host.json

rpm-ostree compose --repo=${OstreeRepoDir} tree ${GitDir}/centos-atomic-host.json |& tee ${BuildDir}/log.compose
if ostree --repo=${OstreeRepoDir} rev-parse centos-atomic-host/7/x86_64/standard^ &>/dev/null; then
    ostree --repo=${OstreeRepoDir} static-delta generate centos-atomic-host/7/x86_64/standard
fi
ostree --repo=${OstreeRepoDir} summary -u |& tee ${BuildDir}/log.compose

# deal with https://bugzilla.gnome.org/show_bug.cgi?id=748959

chmod -R a+r /srv/repo/objects

echo 'Stage-1 done, you can now sign the repo, or just run stage2 '

