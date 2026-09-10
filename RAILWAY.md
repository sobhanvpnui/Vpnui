# VPN-UI — Railway deployment

This archive is prepared for Railway.

## What was changed

- Added a production Dockerfile.
- Builds the bundled/patched Xray core during the Docker build.
- Uses Railway's dynamic `PORT` automatically.
- Persists SQLite, logs, extracted Xray and geo files under `/data`.
- Added `VPNUI_RAILWAY=1` mode.
- In Railway mode, the web panel and userspace Xray core run, while
  kernel/systemd-dependent VPN protocols are intentionally skipped.

## Deploy

1. Create a Railway project and deploy this folder/repository.
2. Add a Railway Volume mounted at `/data`.
3. Deploy.
4. Railway will expose the HTTP service automatically.
5. Set `VPNUI_ADMIN_PASS` (and optionally `VPNUI_ADMIN_USER`) before the first
   deploy if you do not want the default admin/admin credentials.
6. Add your custom domain in Railway Public Networking.

## Important networking limitation

Railway public HTTP networking is not a VPS network interface. It does not give
the container a host Linux kernel/TUN device or systemd. Therefore this build
does NOT pretend that WireGuard, AmneziaWG, IPsec/L2TP/PPTP, GRE, OpenVPN and
similar kernel/daemon protocols are available.

The Xray userspace core can run on Railway. For a raw TCP Xray inbound, create
Railway Networking -> TCP Proxy for the internal Xray port and use the generated
TCP proxy host/port. Railway supports HTTP and TCP exposure on a service.

For WebSocket/HTTP-based Xray transports, use an HTTP-compatible inbound and
Railway's public HTTPS domain.

## Persistence

Mount the Railway Volume at:

    /data

The panel database is:

    /data/db/vpn-ui.db

