ARG VERSION="15.3"
FROM opensuse/leap:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY Berksfile /var/cinc/Berksfile

RUN zypper up -y --skip-interactive && \
    zypper install -y curl iproute2 hostname libffi-devel gcc gcc-c++ make && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    zypper rm -y cinc libffi-devel && rm -rf /var/cinc/ /opt/cinc /etc/cinc /opt/cinc && \
    zypper clean -a

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
