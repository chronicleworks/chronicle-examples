# syntax=docker/dockerfile:1.4
ARG CHRONICLE_BUILDER_IMAGE=blockchaintp/chronicle-builder-${TARGETARCH}
ARG CHRONICLE_VERSION=BTP2.1.0-0.6.1

FROM ${CHRONICLE_BUILDER_IMAGE}:${CHRONICLE_VERSION} as cache
ARG RELEASE=no
ARG FEATURES=""

# Build a layer for incremental compilation and cache it
RUN if [ "${RELEASE}" = "yes" ]; then \
    if [ -n "${FEATURES}" ]; then \
      cargo build --release --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --release --frozen --bin chronicle; \
    fi ; \
  else \
    if [ -n "${FEATURES}" ]; then \
      cargo build --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --frozen --bin chronicle; \
    fi ; \
  fi;

FROM cache as builder
ARG RELEASE=no
ARG FEATURES=""
ARG DOMAIN=artworld

COPY domains/${DOMAIN}/domain.yaml crates/chronicle-domain/domain.yaml
RUN /usr/local/bin/chronicle-domain-lint crates/chronicle-domain/domain.yaml

# Ensure we rebuild from domain.yaml
RUN touch crates/chronicle-domain/domain.yaml
RUN cat crates/chronicle-domain/domain.yaml

RUN if [ "${RELEASE}" = "yes" ]; then \
    if [ -n "${FEATURES}" ]; then \
      cargo build --release --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --release --frozen --bin chronicle; \
    fi \
    && cp target/release/chronicle /usr/local/bin/; \
  else \
    if [ -n "${FEATURES}" ]; then \
      cargo build --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --frozen --bin chronicle; \
    fi \
    && cp target/debug/chronicle /usr/local/bin/; \
  fi;

WORKDIR /
FROM ubuntu:focal AS domain

COPY --from=builder --chown=root:bin /usr/local/bin/chronicle /usr/local/bin
COPY --chown=root:bin entrypoint /entrypoint

RUN apt-get update && \
  apt-get install -y \
  libpq-dev \
  ca-certificates

RUN chmod 755 \
    /entrypoint \
    /usr/local/bin/chronicle

RUN groupadd -g 999 chronicle && \
    useradd -m -r -u 999 -g chronicle chronicle

USER chronicle

ENTRYPOINT [ "/entrypoint" ]
