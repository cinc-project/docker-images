FROM almalinux:8
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

# Set USER and LOGNAME so that vagrant works properly
ENV USER=root
ENV LOGNAME=root

RUN yum -y upgrade && \
    yum -y install yum-utils && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    yum-config-manager --add-repo https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo && \
    yum -y install vagrant VirtualBox-7.0 procps-ng kmod openssh-clients && \
    yum clean all
