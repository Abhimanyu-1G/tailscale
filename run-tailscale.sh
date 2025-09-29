#!/usr/bin/env bash

/render/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
PID=$!

# Wait until tailscale up succeeds
until /render/tailscale up \
  --authkey="${TAILSCALE_AUTHKEY}" \
  --hostname="${RENDER_SERVICE_NAME:-render-exit-node}" \
  --advertise-exit-node \
  --accept-dns=false \
  --reset; do
  sleep 0.5
done

export ALL_PROXY=socks5://localhost:1055/
tailscale_ip=$(/render/tailscale ip)
echo "✅ Tailscale is up at IP ${tailscale_ip} and advertising as exit node"

wait ${PID}
