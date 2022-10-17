ARG VERSION="7"
FROM centos:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

RUN mkdir -p /var/cinc/cache /var/cinc/cookbooks
COPY Berksfile /var/cinc/Berksfile

RUN yum -y upgrade && \
    yum -y install curl iproute hostname && \
    curl -L https://omnitruck.cinc.sh/install.sh | bash && \
    /opt/cinc/embedded/bin/gem install -N berkshelf && \
    /opt/cinc/embedded/bin/berks vendor -b /var/cinc/Berksfile /var/cinc/cookbooks && \
    cinc-solo -o 'recipe[cinc-omnibus]' && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    yum -y remove cinc && rm -rf /var/cinc/ /opt/cinc/ /etc/cinc && \
    yum clean all && rm -rf /var/cache/yum

ENV RUBYOPT=-r/usr/local/share/ruby-docker-copy-patch.rb
