# Complete Setup: Affinity Apps with Clean Wrappers & Icons

---

## Step 1: Create the wrapper script `wine-ew-affinity`

Create a proper executable in `~/.local/bin` (this folder is usually in `$PATH`):

```bash
mkdir -p ~/.local/bin
nano ~/.local/bin/wine-ew-affinity
```

Paste this inside:

```bash
#!/usr/bin/env bash
# Wrapper for Affinity Wine prefix
rum ElementalWarriorWine-x86_64 "$HOME/.local/share/wine/prefixes/affinity/" "$@"
```

Save & exit (CTRL+O, Enter, CTRL+X).

Make it executable:

```bash
chmod +x ~/.local/bin/wine-ew-affinity
```

-> Quick test it works (should launch Publisher 2 manually):

```bash
wine-ew-affinity wine "$HOME/.local/share/wine/prefixes/affinity/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe"
```

---

## Step 2: Install your icons in the correct theme path

KDE & GNOME both follow the freedesktop.org icon spec.

```bash
mkdir -p ~/.local/share/icons/hicolor/256x256/apps/
```

Copy your SVG files & rename consistently:

```bash

cp /home/$USER/Downloads/AffinityOnLinux/Assets/Icons/Designer.svg   ~/.local/share/icons/hicolor/256x256/apps/affinity-designer.svg
cp /home/$USER/Downloads/AffinityOnLinux/Assets/Icons/Photo.svg      ~/.local/share/icons/hicolor/256x256/apps/affinity-photo.svg
cp /home/$USER/Downloads/AffinityOnLinux/Assets/Icons/Publisher.svg  ~/.local/share/icons/hicolor/256x256/apps/affinity-publisher.svg
```

---

## Step 3: Create `.desktop` launchers

### Affinity Designer 2
```bash
nano ~/.local/share/applications/affinity-designer.desktop
```
```ini
[Desktop Entry]
Name=Affinity Designer 2
Exec=wine-ew-affinity wine "C:/Program Files/Affinity/Designer 2/Designer.exe"
Type=Application
StartupNotify=true
Icon=affinity-designer
Categories=Graphics;Design;
```

---

### Affinity Photo 2
```bash
nano ~/.local/share/applications/affinity-photo.desktop
```
```ini
[Desktop Entry]
Name=Affinity Photo 2
Exec=wine-ew-affinity wine "C:/Program Files/Affinity/Photo 2/Photo.exe"
Type=Application
StartupNotify=true
Icon=affinity-photo
Categories=Graphics;Photography;
```

---

### Affinity Publisher 2
```bash
nano ~/.local/share/applications/affinity-publisher.desktop
```
```ini
[Desktop Entry]
Name=Affinity Publisher 2
Exec=wine-ew-affinity wine "C:/Program Files/Affinity/Publisher 2/Publisher.exe"
Type=Application
StartupNotify=true
Icon=affinity-publisher
Categories=Graphics;Publishing;
```

---

## Step 4: Make them executable & update caches

```bash
chmod +x ~/.local/share/applications/affinity-*.desktop
```

**GNOME / Freedesktop menu cache:**
```bash
update-desktop-database ~/.local/share/applications/
```

**KDE Plasma menu & icon cache:**
```bash
kbuildsycoca5
gtk-update-icon-cache ~/.local/share/icons/hicolor
```

---

## Step 5: Pin & Use

- **KDE Plasma**
  - Open App Menu → search *Affinity Designer 2* / *Publisher 2* / *Photo 2*
  - Right‑click → **Pin to Task Manager** or **Add to Desktop**

- **GNOME**
  - Open Activities / App Grid → search the apps
  - Right‑click → **Add to Favorites** (adds to dock)

At this point, you have:
- A reusable **`wine-ew-affinity` wrapper** (clean, shareable)
- All apps showing in menus with **your custom icons**
- Fully pinnable to **taskbar/dock/desktop**
- No manual quoting or alias headaches
