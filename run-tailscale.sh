#!/usr/bin/env bash
set -e

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
PID=$!

# Wait until tailscaled is up, then bring up Tailscale
until /render/tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${RENDER_SERVICE_NAME:-render-exit-node}" \
  --advertise-exit-node \
  --accept-dns=false \
  --reset; do
  echo "Retrying tailscale up..."
  sleep 1
done

export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/render/tailscale ip)
echo "✅ Tailscale is up at IP ${tailscale_ip}, advertising as exit node"

# --- KEEP ALIVE LOOP ---
(
  while true; do
    echo "Keep-alive: $(date)"
    sleep 300   # every 5 minutes
  done
) &

wait ${PID}
