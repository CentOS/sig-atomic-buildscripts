toolbox_base_args="-c ${buildscriptsdir}/config.ini --ostreerepo http://artifacts.ci.centos.org/sig-atomic/rdgo/centos-continuous/ostree/repo"

prepare_image_build() {
    imgtype=$1

    # sudo since -toolbox might have leftover files as root if interrupted
    sudo rm ${build}/images -rf
    mkdir -p ${build}/images/${imgtype}
    cd ${build}

    if ! test -d repo; then
	ostree --repo=repo init --mode=archive-z2
    fi
    ostree --repo=repo remote delete centos-atomic-continuous || true
    ostree --repo=repo remote add --set=gpg-verify=false centos-atomic-continuous http://artifacts.ci.centos.org/sig-atomic/rdgo/centos-continuous/ostree/repo
    # https://github.com/ostreedev/ostree/issues/407
    ostree --repo=repo pull --mirror --disable-fsync --disable-static-deltas --depth=0 --commit-metadata-only centos-atomic-continuous ${ref}

    rev=$(ostree --repo=repo rev-parse ${ref})
    version=$(ostree --repo=repo show --print-metadata-key=version ${ref} | sed -e "s,',,g")

    if curl -L --head -f http://artifacts.ci.centos.org/sig-atomic/${build}/images/${imgtype}/${version}/; then
	echo "Image ${imgtype} at version ${version} already exists"
	exit 0
    fi

    # Ensure we're operating on a clean base
    (cd ${buildscriptsdir} && git clean -dfx && git reset --hard HEAD)
    # Work around https://lists.centos.org/pipermail/ci-users/2016-July/000302.html
    for file in config.ini atomic-centos-continuous.repo cahc.tdl cloud.ks pxelive.ks; do
	sed -i -e 's,https://ci.centos.org/artifacts/,http://artifacts.ci.centos.org/,g' ${buildscriptsdir}/${file}
    done

    cd images/${imgtype}
}

finish_image_build() {
    imgtype=$1
    sudo chown -R -h $USER:$USER ${version}
    ln -s ${version} latest
    cd ..
    rsync --delete --delete-after --stats -Hrlpt ${imgtype}/ sig-atomic@artifacts.ci.centos.org::sig-atomic/${build}/images/${imgtype}/
}
    
