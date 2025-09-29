FROM debian:stable-slim
WORKDIR /render

# Install dependencies
RUN apt-get -qq update \
  && apt-get -qq install -y --no-install-recommends \
    ca-certificates \
    curl \
    iproute2 \
    iptables \
  && apt-get -qq clean \
  && rm -rf /var/lib/apt/lists/*

# Install Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Copy startup script
COPY run-tailscale.sh /render/run-tailscale.sh
RUN chmod +x /render/run-tailscale.sh

# Start tailscale
CMD ["/render/run-tailscale.sh"]
