# Affinity Apps with Clean Wrappers & Icons

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

## Step 2: Download Affinity software icons

You can find and download the icons for Affinity software from this repository's [`Assets/Icons`](/Assets/Icons) folder.

---

## Step 3: Install your icons in the correct theme path

KDE & GNOME both follow the freedesktop.org icon spec.

```bash
mkdir -p ~/.local/share/icons/hicolor/256x256/apps/
```

Copy your SVG files & rename consistently:

For Affinity by Canva's default icon:
```bash
cp /home/$USER/Downloads/Affinity-Canva.svg ~/.local/share/icons/hicolor/256x256/apps/affinity-canva.svg
```

For Affinity by Canva's square circle icon:
```bash
cp /home/$USER/Downloads/Affinity-Canva-Squircle.svg ~/.local/share/icons/hicolor/256x256/apps/affinity-canva.svg
```

For Affinity V1 and V2:
```bash
cp /home/$USER/Downloads/Designer.svg   ~/.local/share/icons/hicolor/256x256/apps/affinity-designer.svg
cp /home/$USER/Downloads/Photo.svg      ~/.local/share/icons/hicolor/256x256/apps/affinity-photo.svg
cp /home/$USER/Downloads/Publisher.svg  ~/.local/share/icons/hicolor/256x256/apps/affinity-publisher.svg
```

---

## Step 4: Create `.desktop` launchers

### Affinity by Canva
```bash
nano ~/.local/share/applications/affinity-canva.desktop
```
```ini
[Desktop Entry]
Name=Affinity by Canva
Exec=wine-ew-affinity wine "C:/Program Files/Affinity/Affinity/Affinity.exe"
Type=Application
StartupNotify=true
Icon=affinity-canva
Categories=Graphics;Deisgn;Publishing;
```
Alternative exec=
```ini
Exec=env 'WINEPREFIX=$HOME/.local/share/wine/prefixes/affinity' wine-ew-affinity '$HOME/.local/share/wine/prefixes/affinity/drive_c/Program Files/Affinity/Affinity/Affinity.exe'
```

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
Alternative exec=
```ini
Exec=env 'WINEPREFIX=$HOME/.local/share/wine/prefixes/affinity' wine-ew-affinity '$HOME/.local/share/wine/prefixes/affinity/drive_c/Program Files/Affinity/Designer 2/Designer.exe'
```

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
Alternative exec=
```ini
Exec=env 'WINEPREFIX=$HOME/.local/share/wine/prefixes/affinity' wine-ew-affinity '$HOME/.local/share/wine/prefixes/affinity/drive_c/Program Files/Affinity/Photo 2/Photo.exe'
```

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
Alternative exec=
```ini
Exec=env 'WINEPREFIX=$HOME/.local/share/wine/prefixes/affinity' wine-ew-affinity '$HOME/.local/share/wine/prefixes/affinity/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe'
```

---

## Step 5: Make them executable & update caches

```bash
chmod +x ~/.local/share/applications/affinity-*.desktop
```

**GNOME / Freedesktop menu cache:**
```bash
update-desktop-database ~/.local/share/applications/
```

**KDE Plasma menu & icon cache:**
```bash
kbuildsycoca6
gtk-update-icon-cache ~/.local/share/icons/hicolor
```

> [!NOTE]
> If you are on KDE Plasma 5, replace `kbuildsycoca6` in the above command with `kbuildsycoca5`.

---

## Step 6: Pin & Use

- **KDE Plasma**
  - Open App Menu → search *Affinity by Canva* / *Affinity Designer 2* / *Publisher 2* / *Photo 2*
  - Right‑click → **Pin to Task Manager** or **Add to Desktop**

- **GNOME**
  - Open Activities / App Grid → search the apps
  - Right‑click → **Add to Favorites** (adds to dock)

At this point, you have:
- A reusable **`wine-ew-affinity` wrapper** (clean, shareable)
- All apps showing in menus with **your custom icons**
- Fully pinnable to **taskbar/dock/desktop**
- No manual quoting or alias headaches
