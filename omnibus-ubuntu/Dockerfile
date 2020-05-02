ARG VERSION="20.04"
FROM ubuntu:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN sed -i -e 's/archive.ubuntu.com/ubuntu.osuosl.org/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade --no-install-recommends -y && \
    apt-get -y -m install --no-install-recommends \
        curl wget ca-certificates iproute2 rsync openssh-client libssl-dev && \
    # Eventually, we will install cinc
    curl -L https://www.chef.io/chef/install.sh | bash -s -- -v 14 && \
    mkdir -p /var/chef/cache /var/chef/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/chef/cookbooks && \
    for dep in windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/chef/cookbooks; done && \
    chef-solo -o 'recipe[omnibus]' && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    apt-get -y remove chef && rm -rf /var/chef/ /opt/chef/embedded/ /etc/chef && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
