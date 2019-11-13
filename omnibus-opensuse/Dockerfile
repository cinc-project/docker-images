ARG VERSION="15"
FROM opensuse/leap:${VERSION}
LABEL MAINTAINER="OSU Open Source Lab <dockerhub@osuosl.org>"

RUN zypper up --skip-interactive && \
    zypper install -y curl wget iproute2 rsync openssh tar gzip hostname rpm-build && \
    # Eventually, we will install cinc
    # TODO: this is currently broken https://github.com/chef/omnitruck/issues/410
    # curl -L https://www.chef.io/chef/install.sh | bash -s -- -v 14 && \
    wget -qO chef.rpm https://packages.chef.io/files/stable/chef/14.14.29/sles/15/chef-14.14.29-1.sles12.x86_64.rpm && \
    rpm -iU chef.rpm && rm -rf chef.rpm && \
    # Install mixlib-install so we can sanely install omnibus-toolchain
    /opt/chef/embedded/bin/gem install -N mixlib-install && \
    /opt/chef/embedded/bin/mixlib-install download -p sles -l 15 omnibus-toolchain && \
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
