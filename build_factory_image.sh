#!/bin/sh
imagefactory --debug base_image --parameter offline_icicle true --file-parameter install_script ./centos-atomic-host-cloud.ks --parameter oz_overrides "{'libvirt': {'memory': 4096, 'image_type': 'qcow2', 'cpus': 2}}" centos-atomic-7.tdl
