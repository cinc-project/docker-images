FROM almalinux:8
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN yum -y upgrade && \
    yum -y install yum-utils && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    yum-config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo && \
    yum -y install vagrant VirtualBox-6.1 procps-ng kmod openssh-clients && \
    yum clean all
