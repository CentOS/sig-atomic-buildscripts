#!/usr/bin/env bash

set -e

# The loops below are too spammy otherwise...
set +x

# Persistent journal by default, because Atomic doesn't have syslog
echo 'Storage=persistent' >> /etc/systemd/journald.conf

# See: https://bugzilla.redhat.com/show_bug.cgi?id=1051816
# and: https://bugzilla.redhat.com/show_bug.cgi?id=1186757
# Keep this in sync with the `install-langs` in the treefile JSON
KEEPLANGS="
pt_BR
fr_FR
de_DE
it_IT
ru_RU
es_ES
en_US
zh_CN
ja_JP
ko_KR
zh_TW
as_IN
bn_IN
gu_IN
hi_IN
kn_IN
ml_IN
mr_IN
or_IN
pa_IN
ta_IN
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
