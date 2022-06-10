ARG VERSION="8"
FROM quay.io/centos/centos:stream${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG TOOLCHAIN_VERSION="2.1.20"
ARG JDK_VER="11"

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
COPY ruby-docker-copy-patch.rb /usr/local/share/ruby-docker-copy-patch.rb

COPY fix-repos.sh /root/fix-repos.sh

RUN bash /root/fix-repos.sh && rm -rf /root/fix-repos.sh && \
    yum -y upgrade && \
    yum -y install curl wget ca-certificates iproute rsync openssh-clients tzdata \
        java-${JDK_VER}-openjdk-devel glibc-langpack-en glibc-locale-source hostname \
        automake && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    mkdir -p /var/cinc/cache /var/cinc/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/cinc/cookbooks && \
    for dep in ark windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/cinc/cookbooks; done && \
    echo "{\"omnibus\":{\"toolchain_version\":\"${TOOLCHAIN_VERSION}\"}}" > /tmp/attr.json && \
    cinc-solo -o 'recipe[omnibus]' -j /tmp/attr.json && \
    rm -rf /tmp/attr.json && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    yum -y remove cinc && rm -rf /var/cinc/ /opt/cinc/ /etc/cinc && \
    yum clean all && rm -rf /var/cache/yum
