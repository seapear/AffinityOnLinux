# 🧩 Affinity Suite on Linux

> ⚠️ New Experimental Installer is currently in development.  
> You can already **try it out**, give feedback, and help refine the release.

---

## 🚀 Overview
Affinity On Linux now includes a **new Lutris‑based installer** that automates nearly everything: prefix setup, Wine 10.18 runner configuration, dependencies, paths, and helper files.

This guide covers how to install and test the updated method using the **Wine 10.18 (Staged Portable Runner)**.

---

## 🧱 Requirements
Before starting, you should have:
- A `.exe` installer for your Affinity app (Photo, Designer, Publisher, or **Affinity by Canva**).  
- The **Lutris client** will install via [Flathub](https://flathub.org/apps/net.lutris.Lutris) or your distro package manager.  
- **winetricks** (needed for dependencies).  
  ```
  sudo apt install winetricks        # Debian/Ubuntu
  sudo dnf install winetricks        # Fedora
  sudo pacman -Sy winetricks         # Arch
  ```

---

## 🧩 New Lutris Install Method
A new, automated YAML installer is in development!

### 1️⃣ Install the Recommended Runner
Download the Wine 10.18 (Staged Portable Runner):  
**https://github.com/seapear/AffinityOnLinux/releases/tag/v10.18-staged**

Extract it to:
```
~/.local/share/lutris/runners/wine/
```
After extraction, you should have:
```
~/.local/share/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine64
```
Check it works:
```
~/.local/share/lutris/runners/wine/GameDirectionWine-x86_64/bin/wine64 --version
```

---

### 2️⃣ Use the New Script
Get the new YAML installer:
**https://github.com/seapear/AffinityOnLinux/blob/main/Guides/Lutris/InstallScripts/Affinity-gd.yaml**

In Lutris:
1. Open **Lutris** → click ➕ → **Install from a local install script**  
2. Select `Affinity-gd.yaml`  
3. Press **Install** → confirm the install path (e.g. `/home/$USER/Games/affinity-suite`)  
4. When prompted, browse for your Affinity `.exe`  
5. Let the setup finish and it will extract metadata, install dependencies, and run the installer automatically.

The script automatically sets the game executable to:  
`$GAMEDIR/drive_c/Program Files/Affinity/Affinity/Affinity.exe`

---

### 3️⃣ (Alternative) Use the Official Lutris Entry
If you’d rather test via the public listing:  
🔗 **https://lutris.net/games/affinity-by-canva/**  

Click **Install**, select your local Affinity installer when prompted, and Lutris will perform a standard setup.

*(Note: the official listing may not yet include the latest Wine 10.18 runner features as it’s being updated.)*

---

## 🎨 Art Assets
You can set icons and artwork for your entry after install:

| Type | Direct Image Link |
|------|------------------|
| **Icon** | [`Affinity-Canva.svg`](https://github.com/seapear/AffinityOnLinux/blob/main/Assets/Icons/Affinity-Canva.svg?raw=true) |
| **Cover** | [`Affinity-Canva-Cover.png`](https://github.com/seapear/AffinityOnLinux/blob/main/Assets/Covers/Affinity-Canva-Cover.png?raw=true) |
| **Banner** | [`Affinity-Canva-Banner.png`](https://github.com/seapear/AffinityOnLinux/blob/main/Assets/Covers/Affinity-Canva-Banner.png?raw=true) |

In Lutris → right‑click your Affinity entry → **Configure → Game info** → paste those URLs.

---

## 🧩 Technical Notes
- **Runner:** `GameDirectionWine-x86_64` (based on Wine 10.18 Staged)  
- **Prefix:** `$GAMEDIR` (`~/<Games>/affinity-suite/`)  
- **Architecture:** win64 (default)  
- **Dependencies:** vcrun2022, dotnet48, corefonts, tahoma, and renderer = Vulkan  

Helper files installed automatically after setup:  
`Windows.winmd` → `system32/winmetadata/`  
`wintypes_shim.dll.so` → `Program Files/Affinity/Affinity/`

---

## 🧪 Testing and Feedback
This new method is still **in pre‑release testing** so feedback or logs are welcome!  
Please open issues or pull requests here:
👉 [https://github.com/seapear/AffinityOnLinux/issues](https://github.com/seapear/AffinityOnLinux/issues)

---

## 📜 Legacy Guide
The original detailed setup (manual runner install, ElementalWarrior & Wine‑TKG forks, etc.) is archived under:  
[`Guides/Lutris/OLD.md`](https://github.com/seapear/AffinityOnLinux/blob/main/Guides/Lutris/OLD.md)

---

### ✅ Quick Summary
| Component | New Version |
|------------|-------------|
| **Wine runner** | `Wine 10.18 (Staged Portable)` |
| **Installer script** | `Affinity-gd.yaml` |
| **Prefix path** | `~/Games/affinity-suite/` |
| **Executable** | `Affinity.exe` |
| **Status** | Experimental / Working under development |
