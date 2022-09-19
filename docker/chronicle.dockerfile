
# Build a sawtooth backed Chronicle
FROM ${CHRONICLE_IMAGE:-chronicle-builder}:${CHRONICLE_VERSION:-local} as domain
COPY domain.yaml chronicle-domain/
RUN cargo build --release --frozen --bin chronicle

# Build an in memory Chronicle
FROM ${CHRONICLE_IMAGE:-chronicle-builder}:${CHRONICLE_VERSION:-local} as domain-inmem
COPY domain.yaml chronicle-domain/
RUN cargo build --release --frozen --features inmem --bin chronicle

WORKDIR /
FROM ubuntu:focal AS example-chronicle
COPY --from=domain /app/target/release/chronicle /usr/local/bin

FROM ubuntu:focal AS example-chronicle-inmem
COPY --from=domain-inmem /app/target/release/chronicle /usr/local/bin
