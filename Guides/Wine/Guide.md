# Affinity On Linux Guide Wine 10.17+

## Why this Guide?
*Affinity applications rely on Windows Runtime (WinRT) APIs like
`Windows.Services.Store.StoreContract`, which older Wine releases didn’t support.
As of **Wine 10.17**, mainline Wine gained functional WinRT type resolution.
With a small helper DLL and metadata file, you can now launch Affinity cleanly across distributions.* 
Thank you @Wanesty for being the first one to discover this update!

---

## ⚙️ Requirements
- **Wine 10.17+** (mainline/devel build)
- **Winetricks**
- **curl**
- About 10 GB of free disk space
- Internet connection

---

## 🧩 Installation Steps

### 1. Install Wine and Winetricks

#### Fedora / Nobara (Recommended method)

Official Fedora mirrors often mix versions, so use WineHQ’s repo for correct 10.17+ packages.

```bash
sudo dnf install curl -y
sudo rm -f /etc/yum.repos.d/winehq.repo
sudo tee /etc/yum.repos.d/winehq.repo <<'EOF'
[winehq-devel]
name=WineHQ packages for Fedora 41
baseurl=https://dl.winehq.org/wine-builds/fedora/41/
enabled=1
gpgcheck=0
EOF
sudo dnf makecache
sudo dnf install winehq-devel -y
```

If installing `winetricks` via `dnf` fails or tries to downgrade Wine, use the **manual script** (safe for any distro including Nobara — see [Manual Winetricks Install](#manual-winetricks-install)).

---

#### Arch / Manjaro

```bash
sudo pacman -S --needed wine winetricks curl
# or, on AUR-based distros:
# yay -S wine winetricks
```

---

#### Ubuntu / Pop OS / Debian

```bash
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq.asc https://dl.winehq.org/wine-builds/winehq.key
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/winehq.asc] https://dl.winehq.org/wine-builds/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/winehq.list'
sudo apt update
sudo apt install --install-recommends winehq-devel winetricks curl -y
```

---

Verify your version:
```bash
wine --version
```
Should return **wine‑10.17** or newer.

---

### 2. Create a clean Wine prefix

```bash
export WINEPREFIX="$HOME/.affinity"
wineboot --init
```

---

### 3. Install runtime dependencies
Install core components Affinity depends on.

```bash
winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11
```
Note: additional options:
- `renderer=vulkan`
- `tahoma` (if you are getting pixelated fonts)

> The .NET 4.8 installation is large and may take 10–20 minutes.

---

### 4. Download required helper files
These add Windows Runtime metadata support Affinity expects.

```bash
cd /tmp
curl -L -o Windows.winmd https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd
curl -L -o wintypes.dll https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so
```

If your download ends with `.dll.so`, rename it:
```bash
mv /tmp/wintypes.dll.so /tmp/wintypes.dll 2>/dev/null || true
```

---

### 5. Install Affinity
> [!NOTE]
> - Affinity apps found here: [Affinity by Canva](https://www.affinity.studio/) | [Version 2](https://affinity.serif.com/v2/) | [Archived](https://archive.org/details/affinity_20251030)
> - Make sure you have your installion file in `~/Downloads`.
> - "$HOME" you may not work and you may need to put in your full path depending on your distro.

```bash
WINEPREFIX="$HOME/.affinity" wine "$HOME/Downloads/Affinity x64.exe"
```
> Adujust *.exe in the path above for V2 Photo/Designer/Publisher, and run 3 times for each installer.

Follow normal installation prompts.
---

### 6. Copy metadata + shim files
```bash
mkdir -p "$WINEPREFIX/drive_c/windows/system32/winmetadata"
cp /tmp/Windows.winmd "$WINEPREFIX/drive_c/windows/system32/winmetadata/"
cp /tmp/wintypes.dll "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/"
```

*(If you installed Photo 2, Designer 2, or Publisher 2 separately, copy into each of their directories.)*

---

### 7. Configure the `wintypes` DLL override
```bash
WINEPREFIX="$HOME/.affinity" winecfg
```
In **Libraries** tab:
1. Type **wintypes** under “New override for library”.
2. Click **Add**, then **Edit**, choose **Native (Windows)**.
3. Click **Apply**, then **OK**.

<img width="409" height="482" alt="image" src="https://github.com/user-attachments/assets/756320cf-5c19-4eb6-a093-7938e0e40aec" />


---

### 8. Launch Affinity
```bash
WINEPREFIX="$HOME/.affinity" wine "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
```
Adjust for Photo 2, Designer 2, or Publisher 2 paths if needed.

---

## 🧠 Troubleshooting

### Manual Winetricks Install
If the Fedora/Nobara package manager fails or tries to remove Wine:

```bash
cd ~
curl -L -o winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
```

Use your local copy instead of the system command:
```bash
WINEPREFIX="$HOME/.affinity" ~/winetricks remove_mono
WINEPREFIX="$HOME/.affinity" ~/winetricks --force dotnet48
```

Optional: install it globally
```bash
sudo mv ~/winetricks /usr/local/bin/winetricks
```

---

### Add Icon to Dock or Panel
- **GNOME / Fedora / Pop OS / Ubuntu default:** open Activities → search *Affinity* → right‑click → **Add to Favorites**.
- **KDE Plasma / Manjaro / Arch:** right‑click the menu entry → **Add to Panel / Pin to Task Manager**.
- **XFCE / others:** panel right‑click → **Add New Item → Launcher → Affinity**.

---

After doing this, **Affinity** will appear alongside your native apps with its custom blue squircle SVG icon.

---

*(If you also install Photo 2, Designer 2, and Publisher 2, you can duplicate and rename the `.desktop` file — just change the `Name`, `Exec`, and `Icon` fields accordingly.)*


---

## ✅ Verified Environments
- **Wine 10.17 (mainline / devel)**
- ✅ **Affinity 3.x (64‑bit)**
- ✅ **Affinity 2.x (64‑bit)**
- ✅ Fedora 42
    - ✅ Nobara 42
- ✅ Arch 2025.03
    - ✅ [Linux 6.17.7-arch1-1](https://discord.com/channels/1281706644073611358/1281706644715208809/1435848291681304687)
- ✅ Ubuntu
    - ✅ [25.04 x86_64](https://discord.com/channels/1281706644073611358/1281706644715208809/1436016587533586623) 
