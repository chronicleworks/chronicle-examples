FROM ${CHRONICLE_IMAGE:-blockchaintp/chronicle-builder}:${CHRONICLE_VERSION:-BTP2.1.0} as domain-inmem

ARG DOMAIN=artworld
ARG RELEASE=no
ARG FEATURES=""
COPY ${DOMAIN}/domain.yaml chronicle-domain/
RUN if [ "${RELEASE}" = "yes" ]; then \
    if [ -n "${FEATURES}" ]; then \
      cargo build --release --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --release --frozen --bin chronicle; \
    fi; \
    cp target/release/chronicle /usr/local/bin/; \
  else \
    if [ -n "${FEATURES}" ]; then \
      cargo build --frozen --features "${FEATURES}" --bin chronicle; \
    else \
      cargo build --frozen --bin chronicle; \
    fi; \
    cp target/debug/chronicle /usr/local/bin/; \
  fi;

WORKDIR /
FROM ubuntu:focal AS example-chronicle-inmem
COPY --from=domain-inmem --chown=root:bin /usr/local/bin/chronicle /usr/local/bin
COPY --chown=root:bin entrypoint /entrypoint
RUN chmod 755 \
  /entrypoint \
  /usr/local/bin/chronicle

ENTRYPOINT [ "/entrypoint" ]
