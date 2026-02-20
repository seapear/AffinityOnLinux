# Set Up Wine 10.17+ for Affinity Apps on Linux 

## Why This Guide?

Affinity apps need Windows Runtime (WinRT) APIs, which older Wine versions lacked. 
You need Wine 10.17 or newer to fix a missing file that previously blocked the installer. The actual WinRT functionality is then provided by adding a separate helper DLL and metadata file.

Thank you [Wanesty](https://codeberg.org/wanesty) for being the first one to discover this update! You may check out [her guide for installing and running Affinity with Wine](https://affinity.liz.pet/).

---

## ⚙️ Requirements

- **Wine 10.17+** (mainline/devel build)
- **Winetricks**
- **curl**
- About 10 GB of free disk space
- Internet connection

---

## 🧩 Installation Steps

> [!NOTE]
> As an alternative to manually set up Wine 10.17+ to install Affinity with the following steps, you may try out [our experimental Affinity On Linux installer script](/Guides/Wine/Script%20Installer) to help streamline Affinity installation under Wine. Follow the instructions on the page to download and run the installer script.

### Step 1: Install Wine and Winetricks

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

If installing `winetricks` via `dnf` fails or tries to downgrade Wine, use the **manual script** (safe for any distro including Nobara, please see [Manual Winetricks Install](#manual-winetricks-install)).

#### Arch / Manjaro

```bash
sudo pacman -S --needed wine winetricks curl
# or, on AUR-based distros:
# yay -S wine winetricks
```

#### Ubuntu / Pop OS / Debian

```bash
sudo dpkg --add-architecture i386
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq.asc https://dl.winehq.org/wine-builds/winehq.key
sudo sh -c 'echo "deb [signed-by=/etc/apt/keyrings/winehq.asc] https://dl.winehq.org/wine-builds/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/winehq.list'
sudo apt update
sudo apt install --install-recommends winehq-devel winetricks curl -y
```

Verify your version:
```bash
wine --version
```
Should return **wine‑10.17** or newer.

### Step 2: Create a clean Wine prefix

```bash
export WINEPREFIX="$HOME/.affinity"
wineboot --init
```

> [!WARNING]
> You might need to change "$HOME/" to your full home folder path like "/home/YourUsername/" so it points to the [absolute](https://www.redhat.com/sysadmin/linux-path-absolute-relative) location. This is a common problem if you're using a shell that doesn't follow standard POSIX rules.

### Step 3: Install runtime dependencies
Install core components Affinity depends on with Winetricks.

```bash
winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11
```

> [!NOTE]
> The .NET 4.8 installation is large and may take 10–20 minutes.

Additional components you may want to install with winetricks if you encounter issues with running Affinity with Wine:
- `renderer=vulkan`
- `dxvk`
- `tahoma` (if you are getting pixelated fonts)

### Step 4: Install Affinity

> [!NOTE]
> - Affinity apps can be found here: [Affinity by Canva](https://www.affinity.studio/download) (use "Enterprise" to get the `exe`) | [Version 2](https://affinity.serif.com/v2/) | [Archived](https://archive.org/details/affinity_20251030)
> - Make sure you have your installation file in `~/Downloads`.
> - "$HOME" you may not work and you may need to put in your full path depending on your distro.

```bash
WINEPREFIX="$HOME/.affinity" wine "$HOME/Downloads/Affinity x64.exe"
```

Adjust *.exe in the path above for V2 Photo/Designer/Publisher, and run 3 times for each installer.

Follow normal installation prompts.

After you finish installing Affinity, if your Wine version is **11 or newer**, you can immediately skip to launching Affinity as instructed at Step 8. Otherwise, continue to Step 5 to 7.

### Step 5: Download required helper files

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

### Step 6: Copy metadata + shim files

```bash
mkdir -p "$WINEPREFIX/drive_c/windows/system32/winmetadata"
cp /tmp/Windows.winmd "$WINEPREFIX/drive_c/windows/system32/winmetadata/"
cp /tmp/wintypes.dll "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/"
```

If you installed Photo 2, Designer 2, or Publisher 2 separately, copy into each of their directories.

### Step 7: Configure the `wintypes` DLL override

```bash
WINEPREFIX="$HOME/.affinity" winecfg
```
In **Libraries** tab:
1. Type **wintypes** under “New override for library”.
2. Click **Add**, then **Edit**, choose **Native (Windows)**.
3. Click **Apply**, then **OK**.

<img width="409" height="482" alt="image" src="https://github.com/user-attachments/assets/756320cf-5c19-4eb6-a093-7938e0e40aec" />

### Step 8: Launch Affinity

```bash
WINEPREFIX="$HOME/.affinity" wine "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
```

Adjust the `drive_c/Program Files` path for Photo 2, Designer 2, or Publisher 2 paths if needed.

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

Optional: install it globally:
```bash
sudo mv ~/winetricks /usr/local/bin/winetricks
```

---

## 🪄 Optional Enhancements After Installation

### Install Affinity Plugin Loader + WineFix  

> **Author:** [Noah C3](https://github.com/noahc3)  
> **Project:** [AffinityPluginLoader + WineFix](https://github.com/noahc3/AffinityPluginLoader/)  
> *This patch is community‑made and **not official**, but it greatly improves runtime stability and fixes the “Preferences not saving” issue on Linux.*

### Purpose

- Provides plugin loading and dynamic patch injection via **Harmony**  
- Restores **on‑the‑fly settings saving** under Wine  
- Temporarily skips the Canva sign‑in dialog (until the browser redirect fix is ready)

### Quick Install (Recommended Method)

Replace paths dynamically as these commands adapt automatically to your prefix and Affinity directory:

```bash
# Define Wine prefix
export WINEPREFIX="$HOME/.affinity"
cd "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/"

# 1.) Download & extract AffinityPluginLoader + WineFix bundle
curl -L -o /tmp/affinitypluginloader-plus-winefix.tar.xz \
  https://github.com/noahc3/AffinityPluginLoader/releases/latest/download/affinitypluginloader-plus-winefix.tar.xz

tar -xf /tmp/affinitypluginloader-plus-winefix.tar.xz -C .

# 2.) Replace launcher for compatibility
mv "Affinity.exe" "Affinity.real.exe"
mv "AffinityHook.exe" "Affinity.exe"
```

Now your existing launchers still work. `wine .../Affinity.exe` automatically loads AffinityPluginLoader & WineFix.

### Verify Installation of AffinityPluginLoader

Run Affinity as before:
```bash
WINEPREFIX="$HOME/.affinity" wine "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity/Affinity.exe"
```
- You should now see **Affinity Plugin Loader** output in your terminal log on startup.  
- Preferences and settings should now save correctly on Linux.

> [!NOTE]
> - Updates to Affinity may overwrite `Affinity.exe`.  
>   - If that happens, re‑extract the `affinitypluginloader-plus-winefix.tar.xz` bundle.
> - *WineFix currently disables Canva sign‑in.* It will be restored in a future patch once the redirect handler is stable.
> - Always download from [Noah C3’s official GitHub releases](https://github.com/noahc3/AffinityPluginLoader/releases).

### Add Icon to Dock or Panel

- **GNOME / Fedora / Pop OS / Ubuntu default:** open Activities → search *Affinity* → right‑click → **Add to Favorites**.
- **KDE Plasma / Manjaro / Arch:** right‑click the menu entry → **Add to Panel / Pin to Task Manager**.
- **XFCE / others:** panel right‑click → **Add New Item → Launcher → Affinity**.

After doing this, **Affinity** will appear alongside your native apps with its custom blue squircle SVG icon.

If you also install Photo 2, Designer 2, and Publisher 2, you can duplicate and rename the `.desktop` file and just change the `Name`, `Exec`, and `Icon` fields accordingly.

---

## 🗑️ Uninstall Affinity and Wine

See [our guide for uninstalling Affinity and Wine](/Guides/Wine/Guide-Uninstall.md).

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
--- 

## 🧾 Credits

- **ElementalWarrior** – creator of [wine‑wintypes.dll‑for‑affinity](https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity)  
- **WineHQ Team** – added WinRT metadata support (MR [#8367](https://gitlab.winehq.org/wine/wine/-/merge_requests/8367))
- **Microsoft** – provider of [Windows.winmd](https://github.com/microsoft/windows-rs) metadata  
- **Guide revision & testing**
    - [Wanesty](https://codeberg.org/wanesty) for finding this [update](https://discord.com/channels/1281706644073611358/1281706644715208809/1434097819547074652)
    – [GameDirection/InterfaceAS](https://join.gamedirection.net) for testing & sumbitting the [guide](https://discord.com/channels/1281706644073611358/1281706644715208809/1435846007295316171)
    - And of course the [AffinityOnLinux](https://join.affinityonlinux.com) community
- **Noah C3** – Creator of [AffinityPluginLoader](https://github.com/noahc3/AffinityPluginLoader) and WineFix  
- **Harmony** library by [Pardeike](https://github.com/pardeike/Harmony)  
