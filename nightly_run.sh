#!/bin/bash

echo '-----'
date
lck=/tmp/nightly.lock

if [ -e $lck ]; then
  echo locked
  exit 1
else
  touch $lck
fi

# clear out working space
docker images --no-trunc |  grep -v IMAGE | awk '{ print  }' | xargs -r docker rmi
rm -rf /srv/*

cd ~/sig-atomic-buildscripts && \
git checkout downstream && \
git pull origin downstream && \
bash ./build_stage1.sh /srv && bash ./build_sign.sh /srv && bash ./build_stage2.sh /srv

bash /root/push-to-master.sh
rm $lck

