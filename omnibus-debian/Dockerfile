ARG VERSION="11"
FROM debian:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG TOOLCHAIN_VERSION="2.1.11"
ARG JDK_VER="11"

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
COPY ruby-docker-copy-patch.rb /usr/local/share/ruby-docker-copy-patch.rb

RUN sed -i -e 's/deb.debian.org/debian.osuosl.org/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get upgrade --no-install-recommends -y && \
    apt-get -y -m install --no-install-recommends \
        curl wget ca-certificates iproute2 rsync openssh-client libssl-dev tzdata \
        openjdk-${JDK_VER}-jdk-headless locales-all && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    mkdir -p /var/cinc/cache /var/cinc/cookbooks && \
    wget -qO- https://supermarket.chef.io/cookbooks/omnibus/download | tar xzC /var/cinc/cookbooks && \
    for dep in ark windows mingw build-essential chef-sugar chef-ingredient git homebrew remote_install seven_zip wix; do \
        wget -qO- https://supermarket.chef.io/cookbooks/${dep}/download | tar xzC /var/cinc/cookbooks; done && \
    echo "{\"omnibus\":{\"toolchain_version\":\"${TOOLCHAIN_VERSION}\"}}" > /tmp/attr.json && \
    cinc-solo -o 'recipe[omnibus]' -j /tmp/attr.json && \
    rm -rf /tmp/attr.json && \
    sed -i -e 's/^env.*//' /home/omnibus/load-omnibus-toolchain.sh && \
    apt-get -y remove cinc && rm -rf /var/cinc/ /opt/cinc /etc/cinc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
