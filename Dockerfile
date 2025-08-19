# 1. Use a builder step to download various dependencies
FROM qgis/qgis:3.44.2-bookworm AS builder

# Install fonts
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        fontconfig \
        git \
        openssh-client \
        graphicsmagick \
        tini \
        tzdata \
        ca-certificates \
        jq \
        curl \
        libc6 && \
    fc-cache -f && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install n8n globally - update versions as needed
RUN npm install -g n8n@1.107.3

# Start with a new clean image and copy over the added files into a single layer
FROM qgis/qgis:3.44.2-bookworm
COPY --from=builder / /

EXPOSE 5678/tcp

ENTRYPOINT ["tini", "--", "n8n", "start"]