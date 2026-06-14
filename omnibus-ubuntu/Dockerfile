ARG VERSION="26.04"
FROM ubuntu:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY --from=shared Berksfile /var/cinc/Berksfile
COPY --from=shared cinc-omnibus-docker /var/cinc/cinc-omnibus-docker
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade --no-install-recommends -y && \
    apt-get -y -m install --no-install-recommends curl ca-certificates \
      libffi-dev libc6-dev gcc g++ make && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus-docker]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    apt-get -y remove cinc && rm -rf /var/cinc/ /opt/cinc /etc/cinc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
