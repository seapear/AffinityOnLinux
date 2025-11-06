# 🪄 Affinity on Linux Installer — Wine 10.17 +

Automated installer for running **Affinity V3 by Canva (Affinity x64.exe)** on **Fedora/Nobara 42** or any Fedora‑based distro that supports **Wine 10.17 +**.

This uses the official **Wine 10.17** mainline build, automatically sets up dependencies, installs required WinRT shim files, and creates a desktop icon with the Canva‑style squircle.

---

## ⚙️ What this script does
* Initializes a clean Wine prefix at `~/.affinity`
* Installs **.NET 4.8**, **VC Runtime 2022**, **core fonts**, pseudo **Windows 11 mode**
* Downloads and configures WinRT metadata (`Windows.winmd`)
* Adds ElementalWarrior’s `wintypes.dll` shim
* Runs the chosen *Affinity x64.exe* installer
* Sets up the `wintypes` DLL override automatically
* Installs the Canva icon + Menu launcher  
  → You’ll get “Affinity by Canva” inside your Applications Menu / Dock

---

## 🧩 Setup Instructions

### Step 1 – Prerequisites
Ensure you have **Wine 10.17 +** installed first.  
If you don’t, follow [WineHQ’s Fedora instructions](https://wiki.winehq.org/Fedora).

Install basic tools:

```bash
sudo dnf install curl git -y
```

---

### Step 2 – Clone the Repository
```bash
git clone https://github.com/YOURUSERNAME/AffinityOnLinux.git
cd AffinityOnLinux
```

*(Replace `YOURUSERNAME` with your GitHub handle.)*

---

### Step 3 – Run the Installer
```bash
bash install_affinity.sh
```

You’ll be prompted:

```
📦  Enter full path to your 'Affinity x64.exe' installer:
```

Example: `/home/you/Downloads/Affinity x64.exe`

After installation finishes, you’ll see:

```
✅  Installation complete!
You can now launch Affinity from your Applications Menu.
```

---

## 🧭 Launcher Details

A shortcut will be created automatically at:

```
~/.local/share/applications/affinity.desktop
```

and will use this icon:

![icon](https://raw.githubusercontent.com/seapear/AffinityOnLinux/main/Assets/Icons/Affinity-Canva-Squircle.svg)

You can edit or rename this file safely if you want to show “Affinity by Canva”.

---

## 🧠 Troubleshooting

**Installer fails to find Winetricks**  
The script downloads Winetricks automatically from its GitHub if DNF repositories are broken or trying to downgrade Wine.

**App works in terminal but not from icon**  
Make sure your desktop entry uses absolute paths, not `~` or `$USER`.  
The script already writes the correct full path (`/home/username/...`).

**Remove Mono warning / use real .NET 4.8**
The installer removes Wine‑Mono and installs .NET 4.8 automatically.  
If you need to reinstall:
```bash
WINEPREFIX="$HOME/.affinity" winetricks --force dotnet48
```

**Uninstall Affinity**
```bash
rm -rf ~/.affinity
rm ~/.local/share/applications/affinity.desktop
```

---

## ✅ Verified Environment

| OS | Wine | Affinity Version | Result |
|----|------|-----------------|--------|
| Fedora 42 / Nobara 42 | 10.17 (mainline) | 3.x (64‑bit) | ✅ Works |
| Fedora 42 / Nobara 42 | 10.17 (mainline) | 2.x (64‑bit) | ✅ Works |
| Arch 2025.03 | 10.17+ | 3.x | ⏳ Untested |
| Ubuntu 24.04 LTS | 10.17+ | 3.x | ⏳ Untested |

