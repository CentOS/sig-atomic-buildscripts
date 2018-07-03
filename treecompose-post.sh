#!/usr/bin/env bash

set -e

# Persistent journal by default, because Atomic doesn't have syslog
echo 'Storage=persistent' >> /etc/systemd/journald.conf

# The loops below are too spammy otherwise...
set +x

# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
# and: https://bugzilla.redhat.com/show_bug.cgi?id=1186757
# Keep this in sync with the `install-langs` in the treefile JSON
KEEPLANGS="
pt_BR
fr
fr_FR
de
de_DE
it
it_IT
ru
ru_RU
es
es_ES
en_US
zh_CN
ja
ja_JP
ko
ko_KR
zh_TW
as
as_IN
bn
bn_IN
gu
gu_IN
hi
hi_IN
kn
kn_IN
ml
ml_IN
mr
mr_IN
or
or_IN
pa
pa_IN
ta
ta_IN
te
te_IN
"

# Filter out locales from glibc which aren't UTF-8 and in the above set.
# TODO: https://github.com/projectatomic/rpm-ostree/issues/526
localedef --list-archive | while read locale; do
    lang=${locale%%.*}
    lang=${lang%%@*}
    if [[ $locale != *.utf8 ]] || ! grep -q "$lang" <<< "$KEEPLANGS"; then
        localedef --delete-from-archive "$locale"
    fi
done

set -x

cp -f /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
build-locale-archive

# Disable firewalld - we include it but don't want it enabled by default
# See https://pagure.io/atomic-wg/issue/372
systemctl disable firewalld
