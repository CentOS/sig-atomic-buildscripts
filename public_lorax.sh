#!/bin/sh -x

# This builds an Anaconda install image capable of interpreting the new rpm-ostree
# kickstart directives - This install image does not contain actual composed trees
# so it must be pointed at an rpm-ostree repo via a network URL

# At the moment, this is known to work with Colin's patched Lorax here:
# http://cbs.centos.org/koji/buildinfo?buildID=175
# lorax-19.6.28-5.atomic.el7.centos

# The completed tree ends up in the $RELNAME directory

DATE=`date +"%m-%d-%Y-%H:%M"`
RELNAME="atomic-anaconda-nightly-$DATE"

lorax -p CentOS -v 7 -r $RELNAME -e subscription-manager -s http://mirror.centos.org/centos/7/os/x86_64/ -s http://cbs.centos.org/repos/atomic7-testing/x86_64/os/ ./$RELNAME


