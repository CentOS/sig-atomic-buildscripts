rm -f /etc/ostree/remotes.d/*.conf
echo 'unconfigured-state=This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.' >> $(ostree admin --print-current-dir).origin
