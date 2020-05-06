FROM docker:latest
LABEL MAINTAINER="Cinc Project <maintainers@cinc.sh>"

ARG VERSION="4.18.108"
ARG GEM_SOURCE=https://packagecloud.io/cinc-project/stable

RUN apk add --update build-base libxml2-dev libffi-dev git openssh-client ruby ruby-dev ruby-etc ruby-webrick && \
    gem install --no-document --source ${GEM_SOURCE} --version ${VERSION} inspec && \
    gem install --no-document --source ${GEM_SOURCE} --version ${VERSION} cinc-auditor-bin && \
    apk del build-base ruby-dev
