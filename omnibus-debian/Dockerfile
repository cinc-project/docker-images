ARG VERSION="12"
FROM debian:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY Berksfile /var/cinc/Berksfile
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade --no-install-recommends -y && \
    apt-get -y -m install --no-install-recommends curl ca-certificates iproute2 \
      libffi-dev libc6-dev gcc g++ make && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    if [ ! -e /usr/bin/mkdir ] ; then ln -s /bin/mkdir /usr/bin/mkdir; fi && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    apt-get -y remove cinc libffi-dev && rm -rf /var/cinc/ /opt/cinc /etc/cinc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
