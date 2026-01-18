FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEPREFIX=/home/dev/.affinity
ENV DISPLAY=:0
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 1. Base packages
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        ca-certificates \
        locales \
        curl \
        wget \
        cabextract \
        unzip \
        xauth \
        x11-xserver-utils \
        xvfb \
        gpg-agent \
        # wine deps (noble uses t64 flavor for many libs)
        libasound2t64 \
        libasound2-plugins \
        libpulse0 \
        libglib2.0-0 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxi6 \
        libxrandr2 \
        libxinerama1 \
        libxcursor1 \
        libfontconfig1 \
        libfreetype6 \
        libglu1-mesa \
        mesa-vulkan-drivers \
        vulkan-tools \
        winbind \
        nano \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# 2. Add WineHQ (devel / mainline) repo
RUN mkdir -pm755 /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq.asc https://dl.winehq.org/wine-builds/winehq.key && \
    sh -c 'echo "deb [signed-by=/etc/apt/keyrings/winehq.asc] https://dl.winehq.org/wine-builds/ubuntu noble main" > /etc/apt/sources.list.d/winehq.list'

# 3. Install Wine devel 10.17+ and winetricks
RUN apt-get update && \
    apt-get install -y --install-recommends \
        winehq-devel \
        winetricks \
    && rm -rf /var/lib/apt/lists/*

# 4. Create non-root user for Wine work
RUN useradd -m -s /bin/bash dev && \
    usermod -aG sudo dev || true

USER dev
WORKDIR /home/dev

# 5. Initialize Wine prefix
RUN wineboot --init || true

# 6. Install core dependencies via winetricks
RUN winetricks -q remove_mono vcrun2022 dotnet48 corefonts win11 || true

# 7. Download helper files for WinRT metadata support
RUN mkdir -p /tmp/affinity-helpers && cd /tmp/affinity-helpers && \
    curl -L -o Windows.winmd \
      https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd && \
    curl -L -o wintypes_shim.dll.so \
      https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so

# 8. Script to finalize Affinity runtime after installation
RUN cat << 'EOF' > /home/dev/setup_affinity_runtime.sh
#!/usr/bin/env bash
set -euo pipefail
export WINEPREFIX="${WINEPREFIX:-$HOME/.affinity}"

HELPER_DIR=/tmp/affinity-helpers
AFFINITY_BASE="$WINEPREFIX/drive_c/Program Files/Affinity/Affinity"

if [ ! -d "$AFFINITY_BASE" ]; then
    echo "Affinity not found at: $AFFINITY_BASE"
    echo "Install Affinity first using: wine \"\$HOME/Downloads/Affinity x64.exe\""
    exit 1
fi

mkdir -p "$WINEPREFIX/drive_c/windows/system32/winmetadata"
cp "$HELPER_DIR/Windows.winmd" \
   "$WINEPREFIX/drive_c/windows/system32/winmetadata/"

# Wine wants wintypes.dll, shim file is .dll.so
cp "$HELPER_DIR/wintypes_shim.dll.so" "$AFFINITY_BASE/wintypes.dll"

echo "WinRT helper files copied."
echo "Now configure wintypes override via: winecfg"
echo "  Libraries -> New override: wintypes -> Add -> Edit -> Native (Windows)."
EOF

RUN chmod +x /home/dev/setup_affinity_runtime.sh

# 9. Convenience launcher
RUN cat << 'EOF' > /home/dev/run_affinity.sh
#!/usr/bin/env bash
export WINEPREFIX="${WINEPREFIX:-$HOME/.affinity}"
wine "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
EOF
RUN chmod +x /home/dev/run_affinity.sh

CMD ["/bin/bash"]
