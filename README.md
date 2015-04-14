# sig-atomic-buildscripts

This contains metadata and build scripts for the CentOS Atomic Host
Images.  For more information, see
http://wiki.centos.org/SpecialInterestGroup/Atomic

### Maintaining the RPMs

Owner: `mailto:Colin Walters <walters@verbum.org>`

The RPM packages are maintained in a combination of the virt7-testing
and atomic7-testing rpmpkg repositories.  Currently with the CBS,
there is no dist-git; the information about where the spec files are
maintained is not known.

But for most of the RPMs maintained in `atomic7-testing`, they're
built either from the Fedora rawhide dist-git (ostree/rpm-ostree), or
from the Feodra epel7 dist-git (hawkey/librepo/libsolv).

### The build process

The scripts used to do nightly builds based on this content are not
quite public yet. By the upcoming CentOS Atomic SIG meeting (Thursday,
April 16) we hope to have these scripts in source control, in the SIG
repo above. The nightly build process will then pull script updates
from the repo for each build. A rough draft of this, along with some
notes:

http://collabedit.com/r38uq

Currently this process is owned by Karanbir Singh.

### Contributing

Discuss on http://lists.centos.org/pipermail/centos-devel/



