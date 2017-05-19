#!/bin/bash

OstreeRepoDir=/srv/repo
BuildDir=$1
BuildDir=$(cd $BuildDir && pwd)

# This is just a placehodler for the sign
ostree --repo=/srv/repo gpg-sign centos-atomic-host/7/x86_64/standard  0x91ba8335

# generate static delta and summary
if ostree --repo=${OstreeRepoDir} rev-parse centos-atomic-host/7/x86_64/standard^ &>/dev/null; then
    ostree --repo=${OstreeRepoDir} static-delta generate centos-atomic-host/7/x86_64/standard
fi

ostree --repo=${OstreeRepoDir} summary -u |& tee ${BuildDir}/log.compose


