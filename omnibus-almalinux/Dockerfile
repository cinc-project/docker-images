ARG VERSION="10"
FROM almalinux:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY --from=shared Berksfile /var/cinc/Berksfile
COPY --from=shared cinc-omnibus-docker /var/cinc/cinc-omnibus-docker

RUN dnf -y upgrade && \
    dnf -y --allowerasing install curl ca-certificates hostname \
        libffi-devel gcc gcc-c++ make && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus-docker]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    dnf -y remove cinc && \
    rm -rf /var/cinc/ /opt/cinc/ /etc/cinc && \
    dnf clean all && rm -rf /var/cache/dnf

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
