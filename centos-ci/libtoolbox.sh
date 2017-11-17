toolbox_base_args="-c ${buildscriptsdir}/config.ini --ostreerepo http://artifacts.ci.centos.org/sig-atomic/rdgo/centos-continuous/ostree/repo"

prepare_image_build() {
    imgtype=$1

    if test ${OSTREE_BRANCH} = "continuous"; then
        imgdir=images
    else
        imgdir=images-${OSTREE_BRANCH}
    fi

    # sudo since -toolbox might have leftover files as root if interrupted
    sudo rm ${build}/${imgdir} -rf
    mkdir -p ${build}/${imgdir}/${imgtype}

    cd ${build}

    if ! test -d repo; then
        ostree --repo=repo init --mode=archive-z2
    fi

    ostree --repo=repo remote delete --if-exists centos-atomic-continuous
    ostree --repo=repo remote add --no-gpg-verify centos-atomic-continuous \
      http://artifacts.ci.centos.org/sig-atomic/rdgo/centos-continuous/ostree/repo

    ostree --repo=repo pull --mirror --disable-fsync --depth=0 \
      --commit-metadata-only centos-atomic-continuous ${ref}

    rev=$(ostree --repo=repo rev-parse ${ref})
    version=$(ostree --repo=repo show --print-metadata-key=version ${ref} | sed -e "s,',,g")

    imgloc=sig-atomic/${build}/${imgdir}/${imgtype}

    if curl -L --head -f http://artifacts.ci.centos.org/${imgloc}/${version}/; then
        echo "Image ${imgtype} at version ${version} already exists"
        exit 0
    fi

    cd ${imgdir}/${imgtype}
}

finish_image_build() {
    imgtype=$1
    sudo chown -R -h $USER:$USER ${version}
    ln -s ${version} latest
    cd ..
    rsync --delete --delete-after --stats -Hrlpt ${imgtype}/ sig-atomic@artifacts.ci.centos.org::${imgloc}/
}
