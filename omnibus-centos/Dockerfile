ARG VERSION="7"
FROM centos:${VERSION}
LABEL MAINTAINER="OSU Open Source Lab <dockerhub@osuosl.org>"

COPY CentOS-Base-x86_64.repo /etc/yum.repos.d/CentOS-Base.repo
RUN yum -y upgrade && \
    yum -y install curl wget ca-certificates iproute rsync openssh-clients && \
    # Eventually, we will install cinc
    curl -L https://www.chef.io/chef/install.sh | bash -s -- -v 14 && \
    mkdir -p /var/chef/cache /var/chef/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/chef/cookbooks && \
    for dep in windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/chef/cookbooks; done && \
    chef-solo -o 'recipe[omnibus]' && \
    yum -y remove chef && rm -rf /var/chef/ /opt/chef/embedded/ /etc/chef && \
    yum clean all && rm -rf /var/cache/yum
