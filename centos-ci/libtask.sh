buildscriptsdir=$(cd ~/sig-atomic-buildscripts && pwd)
build=centos-continuous
OSTREE_BRANCH=${OSTREE_BRANCH:-continuous}
ref=centos-atomic-host/7/x86_64/devel/${OSTREE_BRANCH}
utils=$buildscriptsdir/centos-ci/utils
assembler=quay.io/cgwalters/coreos-assembler:alpha

prepare_job() {
    export WORKSPACE=$HOME/jobs/${JENKINS_JOB_NAME}
    sudo rm ${WORKSPACE} -rf
    mkdir -p ${WORKSPACE}

    export CACHEDIR=$HOME/cache
    mkdir -p ${CACHEDIR}

    export BUILD_LOGS=$HOME/build-logs
    sudo rm ${BUILD_LOGS} -rf
    mkdir ${BUILD_LOGS}

    . ~/rsync-password.sh

    # Work around https://lists.centos.org/pipermail/ci-users/2016-July/000302.html
    for file in config.ini atomic-centos-continuous.repo cahc.tdl cloud.ks vagrant.ks pxelive.ks; do
        sed -i -e 's,https://ci.centos.org/artifacts/,http://artifacts.ci.centos.org/,g' ${buildscriptsdir}/${file}
    done

    sed -i -e 's,^ref *=.*,ref = '${ref}',' ${buildscriptsdir}/config.ini
    grep '^ref =' ${buildscriptsdir}/config.ini

    cd ${WORKSPACE}
}

run_assembler() {
    sudo docker pull ${assembler}
    sudo docker run --user root:root --rm  --entrypoint '' --privileged -v ${buildscriptsdir}:/srv/src -v ${WORKSPACE}:/srv/tmp -v $(cd ~ && pwd):/srv/home -v $(pwd):/srv/build -w /srv/build ${assembler} "$@"
}

# Avoid recursion
if test -z "${WORKSPACE:-}"; then
    prepare_job
fi
