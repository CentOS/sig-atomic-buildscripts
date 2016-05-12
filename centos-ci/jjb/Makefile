all:
	test -d centos-ci-skeleton || git clone https://github.com/cgwalters/centos-ci-skeleton
	cd centos-ci-skeleton && make CENTOSCIPROJECTNAME=atomic CENTOSCINODE=atomic-sig-ci-slave01

update:
	jenkins-jobs --conf jenkins.ini update centos-ci-skeleton/jjb:.
