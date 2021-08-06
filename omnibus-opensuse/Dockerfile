ARG VERSION="15"
FROM opensuse/leap:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG TOOLCHAIN_VERSION="2.1.11"
ARG JDK_VER="11"

RUN zypper up -y --skip-interactive && \
    zypper install -y curl wget iproute2 rsync openssh tar gzip hostname rpm-build \
        java-${JDK_VER}-openjdk-devel && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    # Install mixlib-install so we can sanely install omnibus-toolchain
    /opt/cinc/embedded/bin/gem install -N mixlib-install && \
    /opt/cinc/embedded/bin/mixlib-install download -v ${TOOLCHAIN_VERSION} -p sles -l 15 omnibus-toolchain && \
    rpm -iU omnibus-toolchain-*.rpm && rm -rf omnibus-toolchain-*.rpm && \
    mkdir -p /var/cinc/cache /var/cinc/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/cinc/cookbooks && \
    for dep in ark windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/cinc/cookbooks; done && \
    # Remove omnibus::_omnibus_toolchain recipe since we manually install this
    sed -i -e "s/^include_recipe 'omnibus::_omnibus_toolchain'//g" /var/cinc/cookbooks/omnibus/recipes/default.rb /var/cinc/cookbooks/omnibus/recipes/_user.rb && \
    cinc-solo -o 'recipe[omnibus]' && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    zypper rm -y cinc && rm -rf /var/cinc/ /opt/cinc /etc/cinc /opt/cinc && \
    zypper clean -a
