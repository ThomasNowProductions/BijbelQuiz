# Use Ubuntu as base
FROM ubuntu:22.04

# Set working directory
WORKDIR /workspace

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create vscode user
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable && \
    chown -R vscode:vscode /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Accept Flutter licenses and pre-cache
RUN git config --global --add safe.directory /usr/local/flutter
RUN flutter doctor -v && yes | flutter doctor --android-licenses
