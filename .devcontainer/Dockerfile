# Use Ubuntu as base
FROM ubuntu:22.04

# Set working directory
WORKDIR /workspace

# Install dependencies for Linux toolchain and Android SDK
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
    # Linux toolchain dependencies
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    mesa-utils \
    # Android SDK dependencies
    libc6-dev-i386 \
    lib32stdc++6 \
    lib32gcc-s1 \
    lib32ncurses6 \
    lib32z1 \
    && rm -rf /var/lib/apt/lists/*

# Create vscode user
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT} && \
    chown -R vscode:vscode ${ANDROID_SDK_ROOT}

# Download and install Android Command Line Tools
RUN curl -o /tmp/commandlinetools-linux-14742923_latest.zip https://dl.google.com/android/repository/commandlinetools-linux-14742923_latest.zip && \
    unzip -q /tmp/commandlinetools-linux-14742923_latest.zip -d ${ANDROID_SDK_ROOT} && \
    rm /tmp/commandlinetools-linux-14742923_latest.zip && \
    chown -R vscode:vscode ${ANDROID_SDK_ROOT}

ENV PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${PATH}"

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable && \
    chown -R vscode:vscode /usr/local/flutter && \
    chmod -R 755 /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Accept Flutter licenses and pre-cache as vscode user
USER vscode

# Configure Android SDK path for Flutter
RUN flutter config --android-sdk ${ANDROID_SDK_ROOT}

# Install Android components - move extracted cmdline tools into latest directory
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    find ${ANDROID_SDK_ROOT}/cmdline-tools -maxdepth 1 -not -name 'latest' -not -path "${ANDROID_SDK_ROOT}/cmdline-tools" -exec mv {} ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ \; 2>/dev/null || true

# Accept Android licenses and install required SDK components
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

# Accept Flutter and Android licenses
RUN git config --global --add safe.directory /usr/local/flutter && \
    git config --global --add safe.directory /workspace && \
    flutter doctor -v && \
    yes | flutter doctor --android-licenses

# Switch back to root for any additional setup
USER root
