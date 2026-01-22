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

# Install Miniconda and PDAL
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda 

# Accept Conda ToS
RUN /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    /opt/conda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 

# Install PDAL
RUN /opt/conda/bin/conda install -c conda-forge pdal python-pdal -y && \
    /opt/conda/bin/conda clean -afy

# Expose only the PDAL CLI, not Conda's Python
RUN ln -s /opt/conda/bin/pdal /usr/local/bin/pdal

# Install MinIO Client
RUN curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc && \
  chmod +x $HOME/minio-binaries/mc && \
  export PATH=$PATH:$HOME/minio-binaries/

# Install tippecanoe
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libsqlite3-dev \
        zlib1g-dev && \
    git clone https://github.com/mapbox/tippecanoe.git /tmp/tippecanoe && \
    cd /tmp/tippecanoe && \
    make -j && \
    make install && \
    cd / && \
    rm -rf /tmp/tippecanoe && \
    apt-get remove -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install lastools
RUN curl -fsSL https://downloads.rapidlasso.de/LAStools.tar.gz -o /tmp/LAStools.tar.gz && \
    tar -xzf /tmp/LAStools.tar.gz -C /tmp/LAStools && \
    mv /tmp/LAStools/bin/* /usr/local/bin/ && \
    rm -rf /tmp/LAStools.tar.gz && \
    rm -rf /tmp/LAStools

# Install n8n globally - update versions as needed
RUN npm install -g n8n@1.123.0

EXPOSE 5678/tcp

ENTRYPOINT ["tini", "--", "n8n", "start"]