ARG VERSION="8"
FROM rockylinux:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY Berksfile /var/cinc/Berksfile

RUN dnf -y upgrade && \
    dnf -y --skip-broken install iproute curl libxcrypt-compat hostname \
      libffi-devel gcc make && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    dnf -y remove cinc libxcrypt-compat libffi-devel && \
    rm -rf /var/cinc/ /opt/cinc/ /etc/cinc && \
    dnf clean all && rm -rf /var/cache/dnf

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
