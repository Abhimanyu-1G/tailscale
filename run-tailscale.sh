#!/usr/bin/env bash
set -e

# Start tailscaled in userspace mode WITHOUT SOCKS5 for now
/usr/sbin/tailscaled --tun=userspace-networking &
PID=$!

# Wait until tailscaled is ready, then bring up Tailscale
until tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${RENDER_SERVICE_NAME:-render-exit-node}" \
  --advertise-exit-node \
  --accept-dns=false \
  --reset; do
  echo "Retrying tailscale up..."
  sleep 1
done

tailscale_ip=$(tailscale ip)
echo "✅ Tailscale is up at IP ${tailscale_ip}, advertising as exit node"

# Start nginx in background
nginx -g "daemon off;" &
NGINX_PID=$!

# Keep-alive loop
(
  while true; do
    echo "Keep-alive: $(date)"
    sleep 300
  done
) &

# Wait for both nginx and tailscaled
wait ${PID} ${NGINX_PID}
