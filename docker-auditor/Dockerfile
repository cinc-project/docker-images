ARG TARGETPLATFORM

FROM docker:latest AS base-amd64
FROM docker:latest AS base-arm64
FROM osuosl/docker-ppc64le:latest AS base-ppc64le
FROM osuosl/docker-s390x:latest AS base-s390x

FROM base-${TARGETPLATFORM##*/} AS final

LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

COPY Gemfile /Gemfile

RUN apk add --update build-base libxml2-dev libffi-dev git openssh-client ruby ruby-dev \
      ruby-etc ruby-webrick ruby-bundler && \
    bundle install --system && \
    # For some reason this dep is missing so add it manually
    gem install --no-document bigdecimal && \
    apk del build-base ruby-dev
