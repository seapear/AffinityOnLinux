#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# install_affinity.sh — Fedora/Nobara automated installer for Affinity V3 on Wine 10.17+
# ---------------------------------------------------------------------------
# Author: interfaceas / GameDirection
# Version: 1.0
# Tested: Fedora 42 / Nobara 42 with Wine 10.17+
# ---------------------------------------------------------------------------

set -e

PREFIX="$HOME/.affinity"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
AFFINITY_DIR="$PREFIX/drive_c/Program Files/Affinity/Affinity"
DESKTOP_FILE="$DESKTOP_DIR/affinity.desktop"

# ---------------------------------------------------------------------------
echo "🪄  Affinity V3 (Affinity x64.exe) Installer for Fedora — Wine 10.17+"
echo "--------------------------------------------------------------------"
echo

# Ask for installer file
read -rp "📦  Enter full path to your 'Affinity x64.exe' installer: " INSTALL_PATH
if [[ ! -f "$INSTALL_PATH" ]]; then
    echo "❌  File not found: $INSTALL_PATH"
    exit 1
fi

# Ensure curl is available
sudo dnf install curl -y

# ---------------------------------------------------------------------------
echo "➡️  Creating Wine prefix at $PREFIX ..."
export WINEPREFIX="$PREFIX"
wineboot --init

# ---------------------------------------------------------------------------
echo "➡️  Installing dependencies (this may take a while)..."
if ! command -v winetricks >/dev/null 2>&1; then
  echo "⚠️  Winetricks not found; installing from source..."
  cd ~
  curl -L -o winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
  chmod +x winetricks
  WINETRICKS="$HOME/winetricks"
else
  WINETRICKS="winetricks"
fi

$WINETRICKS --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11

# ---------------------------------------------------------------------------
echo "➡️  Downloading helper files..."
cd /tmp
curl -L -o Windows.winmd https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd
curl -L -o wintypes.dll https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so
mv wintypes.dll.so wintypes.dll 2>/dev/null || true

# ---------------------------------------------------------------------------
echo "➡️  Running Affinity installer..."
WINEPREFIX="$PREFIX" wine "$INSTALL_PATH"

# ---------------------------------------------------------------------------
echo "➡️  Placing helper files..."
mkdir -p "$PREFIX/drive_c/windows/system32/winmetadata"
cp /tmp/Windows.winmd "$PREFIX/drive_c/windows/system32/winmetadata/"

mkdir -p "$AFFINITY_DIR"
cp /tmp/wintypes.dll "$AFFINITY_DIR/"

# Configure DLL override
echo "➡️  Configuring DLL override (wintypes -> native)..."
cat > "$PREFIX/drive_c/Temp/override.reg" <<'EOF'
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"wintypes"="native"
EOF
WINEPREFIX="$PREFIX" wine regedit "$PREFIX/drive_c/Temp/override.reg"
rm -f "$PREFIX/drive_c/Temp/override.reg"

# ---------------------------------------------------------------------------
echo "➡️  Creating desktop launcher..."
mkdir -p "$ICON_DIR" "$DESKTOP_DIR"

# Download Canva squircle icon
curl -L -o "$ICON_DIR/affinity.svg" https://raw.githubusercontent.com/seapear/AffinityOnLinux/main/Assets/Icons/Affinity-Canva-Squircle.svg

# Write .desktop file
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Affinity
Comment=Affinity V3 by Canva via Wine
Exec=bash -c 'env WINEPREFIX="$PREFIX" wine "$AFFINITY_DIR/Affinity.exe"'
Type=Application
StartupNotify=true
Icon=$ICON_DIR/affinity.svg
Categories=Graphics;Photography;Design;
Path=$AFFINITY_DIR
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# ---------------------------------------------------------------------------
echo
echo "✅  Installation complete!"
echo "You can now launch Affinity from your Applications Menu (look for the Canva‑style blue icon)."
echo "Executable: wine \"$AFFINITY_DIR/Affinity.exe\""
echo "Prefix path: $PREFIX"
echo
echo "💡  Tip: To uninstall, just delete $PREFIX and the desktop entry at $DESKTOP_FILE."
echo "--------------------------------------------------------------------"
