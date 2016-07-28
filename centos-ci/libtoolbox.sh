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

    if test ${OSTREE_BRANCH} = "continuous"; then
	imgloc=sig-atomic/${build}/images/${imgtype}
    else
	imgloc=sig-atomic/${build}/images-${OSTREE_BRANCH}/${imgtype}
    fi

    if curl -L --head -f http://artifacts.ci.centos.org/${imgloc}/${version}/; then
	echo "Image ${imgtype} at version ${version} already exists"
	exit 0
    fi

    cd images/${imgtype}
}

finish_image_build() {
    imgtype=$1
    sudo chown -R -h $USER:$USER ${version}
    ln -s ${version} latest
    cd ..
    rsync --delete --delete-after --stats -Hrlpt ${imgtype}/ sig-atomic@artifacts.ci.centos.org::${imgloc}/
}
    
