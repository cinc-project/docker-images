ARG VERSION="8"
FROM centos:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

COPY fix-repos.sh /root/fix-repos.sh
RUN bash /root/fix-repos.sh && rm -rf /root/fix-repos.sh && \
    yum -y upgrade && \
    yum -y install curl wget ca-certificates iproute rsync openssh-clients && \
    # Eventually, we will install cinc
    curl -L https://www.chef.io/chef/install.sh | bash -s -- -v 14 && \
    mkdir -p /var/chef/cache /var/chef/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/chef/cookbooks && \
    for dep in windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/chef/cookbooks; done && \
    chef-solo -o 'recipe[omnibus]' && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    yum -y remove chef && rm -rf /var/chef/ /opt/chef/embedded/ /etc/chef && \
    yum clean all && rm -rf /var/cache/yum
