FROM almalinux:9
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

# Set USER and LOGNAME so that vagrant works properly
ENV USER=root
ENV LOGNAME=root

RUN yum -y upgrade && \
    yum -y install yum-utils && \
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo && \
    yum -y install vagrant procps-ng kmod rsync openssh-clients && \
    vagrant plugin install vagrant-openstack-provider && \
    yum clean all
