# syntax=docker/dockerfile:1

FROM golang:1.26-bookworm AS builder
WORKDIR /src

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl ca-certificates build-essential pkg-config \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# The source archive does not contain initialized git submodules. Clone the
# project's patched Xray fork so the final self-contained binary has Xray + geo data.
RUN rm -rf third_party/Xray-core \
    && git clone --depth 1 https://github.com/Sir-MmD/Xray-core.git third_party/Xray-core \
    && GEO_LEAN=1 ./build.sh --skip-submodules --skip-bundle

FROM debian:bookworm-slim AS runtime
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata bash curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /data/db /data/bin /data/logs /data/cert

COPY --from=builder /src/build/out/vpn-ui-amd64 /app/vpn-ui-amd64
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/vpn-ui-amd64 /app/entrypoint.sh

ENV VPNUI_RAILWAY=1 \
    VPNUI_DB_FOLDER=/data/db \
    VPNUI_BIN_FOLDER=/data/bin \
    VPNUI_LOG_FOLDER=/data/logs \
    VPNUI_DEBUG=false \
    VPNUI_LOG_LEVEL=info \
    TZ=UTC

EXPOSE 8080

ENTRYPOINT ["/app/entrypoint.sh"]
