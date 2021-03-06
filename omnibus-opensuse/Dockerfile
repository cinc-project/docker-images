ARG VERSION="15"
FROM opensuse/leap:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG TOOLCHAIN_VERSION="2.0.5"
ARG JDK_VER="11"

RUN zypper up -y --skip-interactive && \
    zypper install -y curl wget iproute2 rsync openssh tar gzip hostname rpm-build \
        java-${JDK_VER}-openjdk-devel && \
    # Eventually, we will install cinc
    curl -L https://www.chef.io/chef/install.sh | bash -s -- -v 14 && \
    # Install mixlib-install so we can sanely install omnibus-toolchain
    /opt/chef/embedded/bin/gem install -N mixlib-install && \
    /opt/chef/embedded/bin/mixlib-install download -v ${TOOLCHAIN_VERSION} -p sles -l 15 omnibus-toolchain && \
    rpm -iU omnibus-toolchain-*.rpm && rm -rf omnibus-toolchain-*.rpm && \
    mkdir -p /var/chef/cache /var/chef/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/chef/cookbooks && \
    for dep in windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/chef/cookbooks; done && \
    # Remove omnibus::_omnibus_toolchain recipe since we manually install this
    sed -i -e "s/^include_recipe 'omnibus::_omnibus_toolchain'//g" /var/chef/cookbooks/omnibus/recipes/default.rb /var/chef/cookbooks/omnibus/recipes/_user.rb && \
    chef-solo -o 'recipe[omnibus]' && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    zypper rm -y chef && rm -rf /var/chef/ /opt/chef/embedded/ /etc/chef /opt/chef && \
    zypper clean -a
