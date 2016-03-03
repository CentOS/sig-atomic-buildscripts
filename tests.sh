#!/bin/bash
# This is just a list of things we need to test for.
# - ensure all rpms we consume are from the prod repos
# - ensure all rpms going into the build are signed.

# Validate content/ostree-repo
# - ensure we are signed with the right key
# - ensure the remote url is functional
# - ensure we can pull the default ostree remote repo, and is signed

# Validate images
# - instantiate each image in its native environ ( eg. vbox/vagrant or libvirt/vagrant )
# - ensure we can login
# - ensure docker service is functional
# - ensure cockpit needed infra is in place
# - ensure docker can run a generic container
# - ensure docker running container can execute t_functional(?)/lightweight

