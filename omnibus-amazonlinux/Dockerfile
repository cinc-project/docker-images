ARG VERSION="2"
FROM amazonlinux:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG TOOLCHAIN_VERSION="2.1.11"
ARG JDK_VER="11"

RUN yum -y upgrade && \
    yum -y install curl wget ca-certificates tar hostname iproute rsync openssh-clients rpm-build \
        java-${JDK_VER}-amazon-corretto-headless && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    mkdir -p /var/cinc/cache /var/cinc/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/cinc/cookbooks && \
    for dep in ark windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/cinc/cookbooks; done && \
    echo "{\"omnibus\":{\"toolchain_version\":\"${TOOLCHAIN_VERSION}\"}}" > /tmp/attr.json && \
    cinc-solo -o 'recipe[omnibus]' -j /tmp/attr.json && \
    rm -rf /tmp/attr.json && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    yum -y remove cinc && rm -rf /var/cin/ /opt/cinc/embedded/ /etc/cinc && \
    yum clean all && rm -rf /var/cache/yum
