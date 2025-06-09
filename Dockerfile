# SPDX-License-Identifier: Apache-2.0
#
# Copyright (c) 2021-2022 Patrick Dung

FROM docker.io/golang:1.21-bookworm AS build

ARG ARCH
## With Docker's buildx, TARGETARCH gives out amd64/arm64
##ARG TARGETARCH
ARG RELEASE_VERSION

# do not remove below line
WORKDIR /goatcounter

    ##-ldflags="-X zgo.at/goatcounter/v2.Version=$(git log -n1 --format='%h_%cI') -extldflags=-static" \
RUN set -eux && \
    git clone --single-branch https://github.com/arp242/goatcounter.git -b ${RELEASE_VERSION} ./goatcounter && \
    cd ./goatcounter && \
    export GIT_VERSION_TAG=$(git log -n1 --format='%h_%cI') && \
    go build -tags osusergo,netgo,sqlite_omit_load_extension \
      -ldflags="-X zgo.at/goatcounter/v2.Version=${GIT_VERSION_TAG} -extldflags=-static" \
      ./cmd/goatcounter && \
    pwd && ls -lR

#FROM quay.io/almalinuxorg/9-minimal:9
FROM quay.io/rockylinux/rockylinux:9-minimal

ARG LABEL_IMAGE_URL
ARG LABEL_IMAGE_SOURCE

LABEL org.opencontainers.image.url=${LABEL_IMAGE_URL}
LABEL org.opencontainers.image.source=${LABEL_IMAGE_SOURCE}

RUN set -eux && \
    microdnf \
      --nodocs --setopt=install_weak_deps=0 --setopt=keepcache=0 \
      -y install shadow-utils tar postgresql && \
    microdnf -y upgrade && \
    microdnf clean all && \
    rm -rf /var/cache/yum && \
    groupadd \
      --gid 20000 \
      goatcounter && \
    useradd --no-log-init \
      --create-home \
      --home-dir /home/goatcounter \
      --shell /bin/bash \
      --uid 20000 \
      --gid 20000 \
      --key MAIL_DIR=/dev/null \
      goatcounter && \
    mkdir -p /home/goatcounter/bin /home/goatcounter/db && \
    chown -R goatcounter:goatcounter /home/goatcounter

COPY --from=build --chown=goatcounter:goatcounter /goatcounter/goatcounter/goatcounter /home/goatcounter/bin
COPY entrypoint.sh /entrypoint.sh
COPY goatcounter.sh /home/goatcounter/bin

USER goatcounter
WORKDIR /home/goatcounter
VOLUME /home/goatcounter/db
EXPOSE 8080/tcp

ENV GOATCOUNTER_LISTEN=0.0.0.0:8080
ENV GOATCOUNTER_TLS=http
#ENV GOATCOUNTER_DB='sqlite://db/goatcounter.sqlite3?_busy_timeout=200&_journal_mode=wal&cache=shared'
#ENV GOATCOUNTER_DB='sqlite+db/goatcounter.sqlite3?_busy_timeout=200&_journal_mode=wal&cache=shared'

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/home/goatcounter/bin/goatcounter.sh"]
