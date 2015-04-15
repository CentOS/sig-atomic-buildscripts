# sig-atomic-buildscripts

This contains metadata and build scripts for the CentOS Atomic Host
Images.  For more information, see
http://wiki.centos.org/SpecialInterestGroup/Atomic

### The build process

Builds are run every 12 hrs from cron. 

As step-1, the machine is updated to consume the latest content from 
CentOS Linux, Atomic SIG testing, Virt SIG testing.

Then a script is run to generate the artifacts and sent to a push server
this is the build_ostree_components.sh script.

Resulting artifacts are delivered to :
 * http://buildlogs.centos.org/centos/7/atomic/x86_64/repo/
 * http://buildlogs.centos.org/centos/7/atomic/x86_64/Builds/

Currently this process is owned by Karanbir Singh.

### Contributing

Discuss on http://lists.centos.org/pipermail/centos-devel/



