# Based on projectatomic/rpm-ostree libvm.sh

export LIBVIRT_DEFAULT_URI=qemu:///system

vm_setup() {
    ip=$1; shift
    SSH="ssh -o UserKnownHostsFile=/dev/null \
             -o StrictHostKeyChecking=no \
             root@$ip"
}

# run command in vm
# - $@    command to run
vm_cmd() {
  $SSH "$@"
}

# wait until ssh is available on the vm
# - $1    timeout in second (optional)
# - $2    previous bootid (optional)
vm_ssh_wait() {
  timeout=${1:-0}; shift
  old_bootid=${1:-}; shift
  while [ $timeout -gt 0 ]; do
    if bootid=$(vm_get_boot_id 2>/dev/null); then
        if [[ $bootid != $old_bootid ]]; then
            return 0
        fi
    fi
    if test $(($timeout % 5)) == 0; then
        echo "Still failed to log into VM, retrying for $timeout seconds"
    fi
    timeout=$((timeout - 1))
    sleep 1
  done
  if ! vm_cmd true; then
     echo "Failed to log into VM, retrying with debug:"
     $SSH -o LogLevel=debug true || true
  fi
  false "Timed out while waiting for SSH."
}

vm_get_boot_id() {
  vm_cmd cat /proc/sys/kernel/random/boot_id
}

# reboot the vm
vm_reboot() {
  bootid=$(vm_get_boot_id 2>/dev/null)
  vm_cmd systemctl reboot || :
  vm_ssh_wait 120 $bootid
}

