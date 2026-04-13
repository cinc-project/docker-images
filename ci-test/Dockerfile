ARG VERSION="13"
FROM debian:${VERSION}
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ENV DEBIAN_FRONTEND=noninteractive
ENV ERLANG_VERSION=26.2.5.14
ENV ELVIS_VERSION=4.2.3
ENV RUBY_VERSION=3.1
ENV LANG=en_US.UTF-8

# Install base build dependencies
RUN apt-get update && \
    apt-get upgrade --no-install-recommends -y && \
    apt-get -y -m install --no-install-recommends \
      build-essential autoconf automake libncurses5-dev libssl-dev \
      curl ca-certificates git \
      postgresql postgresql-client libpq-dev \
      lua5.1 liblua5.1-0-dev luarocks \
      ruby ruby-dev ruby-bundler \
      libsqlite3-dev libffi-dev \
      locales procps && \
    localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Erlang via kerl
RUN curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl && \
    chmod +x kerl && mv kerl /usr/local/bin/ && \
    kerl update releases && \
    kerl build ${ERLANG_VERSION} ${ERLANG_VERSION} && \
    kerl install ${ERLANG_VERSION} /opt/erlang/${ERLANG_VERSION} && \
    kerl cleanup all

ENV PATH="/opt/erlang/${ERLANG_VERSION}/bin:${PATH}"

# Install rebar3
RUN curl -O https://s3.amazonaws.com/rebar3/rebar3 && \
    chmod +x rebar3 && mv rebar3 /usr/local/bin/

# Install elvis (Erlang style checker) - build from source as escript
RUN git clone --depth 1 --branch ${ELVIS_VERSION} https://github.com/inaka/elvis.git /tmp/elvis && \
    cd /tmp/elvis && rebar3 escriptize && \
    cp _build/default/bin/elvis /usr/local/bin/elvis && \
    chmod +x /usr/local/bin/elvis && \
    rm -rf /tmp/elvis

# Install Lua libraries
RUN luarocks install lpeg && \
    luarocks install lua-cjson

# Install sqitch
RUN apt-get update && \
    apt-get -y -m install --no-install-recommends \
      cpanminus libdbd-pg-perl && \
    cpanm --notest --quiet App::Sqitch && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure PostgreSQL to allow local trust connections for CI
RUN sed -i 's/peer/trust/g' /etc/postgresql/*/main/pg_hba.conf && \
    sed -i 's/scram-sha-256/trust/g' /etc/postgresql/*/main/pg_hba.conf

WORKDIR /workdir
