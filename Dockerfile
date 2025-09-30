# Use lightweight Debian as base
FROM debian:stable-slim
WORKDIR /render

# Install dependencies
RUN apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    curl \
    iproute2 \
    iptables \
    nginx \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy HTML file
COPY index.html /usr/share/nginx/html/index.html

# Copy startup script
COPY run-tailscale.sh /render/run-tailscale.sh
RUN chmod +x /render/run-tailscale.sh

# Expose HTTP + Tailscale
EXPOSE 80 443

# Run startup script (starts Tailscale + Nginx)
CMD ["/render/run-tailscale.sh"]
