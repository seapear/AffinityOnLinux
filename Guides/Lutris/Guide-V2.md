# 🧩 How to Set Up Wine 10.17+ for Affinity on Lutris

> ⚠️ New Experimental Installer is currently in development.  
> You can already **try it out**, give feedback, and help refine the release.

## 📜 Legacy Guide
The original detailed setup (manual runner install, ElementalWarrior & Wine‑TKG forks, etc.) is archived under:  
[`Guides/Lutris/Guide.md`](./Guide.md)

---

## 🚀 Overview
Affinity On Linux now includes a **new Lutris‑based installer** that automates nearly everything: prefix setup, Wine 10.19 runner configuration, dependencies, paths, and helper files.

This guide covers how to install and test the updated method using the **[Wine 10.19](https://github.com/seapear/AffinityOnLinux/releases/tag/v10.19-staged) (Staged Portable Runner)**.

---

## 🧱 Requirements
Before starting, you should have:
- An `.exe` installer of your Affinity app (Photo, Designer, Publisher) if you use Version 2 of Affinity Suite (v3, or Affinity By Canva will be downloaded and installed  by our Lutris script automatically).
- **Lutris** — you can install it via [Flathub](https://flathub.org/apps/net.lutris.Lutris) or your distro package manager. You can check out the [download page of Lutris' official website](https://lutris.net/downloads) and follow the instructions to download and install it. 
- **winetricks** (needed for dependencies).  
  ```
  sudo apt install winetricks        # Debian/Ubuntu
  sudo dnf install winetricks        # Fedora
  sudo pacman -Sy winetricks         # Arch
  ```

---

## 🧩 New Lutris Install Method

> [!NOTE]
> After you installed Lutris, make sure to launch Lutris at least once to generate the folder structure.

### 1️⃣ Install the Recommended Runner

Visit this repository's [release page of Wine 10.19 (Staged Portable Runner)](https://github.com/seapear/AffinityOnLinux/releases/tag/v10.19-staged). Scroll down until you see the **Assets** section, download the `GameDirectionWine-x86_64.tar.xz` file, then right click and extract it. You should have a folder now called `GameDirectionWine-x86_64`.

Lutris' Wine-related folders can be found in a hidden directory within your `home` folder. If you can't see hidden folders in your file browser, you can usually enable them by pressing `Ctrl + H`.

- If you installed Lutris via **Flatpak**, navigate to `/home/$USER/.var/app/net.lutris.Lutris/data/lutris/runners/`
- If you installed Lutris via other methods, navigate to `/home/$USER/.local/share/lutris/runners/`

Create a folder called `wine` if one does not already exist, then copy and paste the Wine fork folder you extracted to this folder.

After extraction, you should have this folder path:
- If you installed Lutris with Flatpak: `/home/$USER/.var/app/net.lutris.Lutris/data/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine`
- If you installed Lutris via other methods: `/home/$USER/.local/share/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine`

Check if the Wine runner works by running the following command in the terminal:
- If you installed Lutris via Flatpak:
  ```shell
  /home/$USER/.var/app/net.lutris.Lutris/data/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine --version
  ```
- If you installed Lutris via other methods:
  ```bash
  /home/$USER/.local/share/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine --version
  ```
If it works, the terminal should output a version number of the Wine runner.

---

### Use the New Lutris Install Script

1. Visit the [new Lutris install script in this repository](/Guides/Lutris/InstallScripts/Affinity-gd.yaml), then click the download button located on the top right of the file content to download it as a YAML file named `Affinity-gd.yaml`.
2. Open **Lutris** → click ➕ → **Install from a local install script**  
3. Select `Affinity-gd.yaml`  
4. Press **Install** → confirm the install path (e.g. `/home/$USER/Games/affinity-suite`)  
5. When prompted, set to "download" to get the latest version of the installer or browse for your Affinity `.exe`.
6. Let the setup finish and it will extract metadata, install dependencies, and run the installer automatically.

The script automatically sets the game executable to:  
`$GAMEDIR/drive_c/Program Files/Affinity/Affinity/Affinity.exe`

---

### 3️⃣ (Alternative) Use the Official Lutris Entry
If you’d rather test via the public listing:  
🔗 **https://lutris.net/games/affinity-by-canva/**  

Click **Install**, select your local Affinity installer when prompted, and Lutris will perform a standard setup.

*(Note: the official listing may not yet include the latest Wine 10.19 runner features as it's reliant on [Official Lutris Runner List](https://lutris.net/api/runners).)*

---

## 🎨 Art Assets

You can find and download icons, cover art and banners for Affinity apps from AffinityOnLinux repository's [`Icons`](/Assets/Icons) and [`Covers`](/Assets/Covers) folders.

To set these art assets In Lutris, launch Lutris, right‑click your Affinity app entry, then select **Configure**. Under the **Game info** tab, click on each square or rectangle and upload the icon, cover and banner art you downloaded from this repository.

---

## 🧩 Technical Notes
- **Runner:** `GameDirectionWine-x86_64` (based on Wine 10.19 Staged)  
- **Prefix:** `$GAMEDIR` (default: `/home/$USER/Games/affinity-suite/`)  
- **Architecture:** win64 (default)  
- **Dependencies:** vcrun2022, dotnet48, corefonts, tahoma, and renderer = Vulkan  

Helper files installed automatically after setup:  
`Windows.winmd` → `system32/winmetadata/`  
`wintypes_shim.dll.so` → `Program Files/Affinity/Affinity/`

---

## 🧪 Issues and Feedback
Please open issues or pull requests here:
👉 [https://github.com/seapear/AffinityOnLinux/issues](https://github.com/seapear/AffinityOnLinux/issues)

---

### ✅ Quick Summary
| Component | New Version |
|------------|-------------|
| **Wine runner** | `Wine 10.19 (Staged Portable)` |
| **Installer script** | `Affinity-gd.yaml` |
| **Prefix path** | `/home/$USER/Games/affinity-suite/` |
| **Executable** | `Affinity.exe` |
| **Status** | Experimental / Working under development |
