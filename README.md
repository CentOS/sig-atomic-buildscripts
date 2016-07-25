# sig-atomic-buildscripts

This contains metadata and build scripts for the CentOS Atomic Host
Development stream.  See:

https://wiki.centos.org/SpecialInterestGroup/Atomic/Devel

If you're interested in scripts for the CentOS Core SIG rebuild
of EL7, see the "downstream" branch.

Discuss on http://lists.centos.org/pipermail/centos-devel/
and https://lists.projectatomic.io/projectatomic-archives/atomic-devel/




# Performing ostree/rpm-ostree updates to CBS

First, ensure the RPM is built in Fedora, rawhide at least, and
normally all stable releases.  Now:

```
cd ~/src/distgit/fedora/ostree
rpmbuild-cwd --define 'dist .el7.centos' -bs *.spec
koji -p cbs build atomic7-el7.centos ostree-2016.7-1.el7.centos.src.rpm
```
