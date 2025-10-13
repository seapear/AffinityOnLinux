# Guides for Running Affinity Suite with Wine Managers

Click to the folder of your Wine manager for a guide to run Affinity Suite with your Wine manager of choice.

Cover art and banners can be found on the repository's [`Assets/Covers`](/Assets/Covers) directory.

[Lutris](https://github.com/seapear/AffinityOnLinux/blob/main/Guides/Lutris/Guide.md) is recommended.

## Enabling Dark Theme in Wine

### Step 1: Download the Registry File

- Visit the [wine-dark-theme.reg](/Auxiliary/Other/wine-dark-theme.reg) file in this repository.
- Click the Download button (top-right of the page) to save it to your machine.

---

### Step 2: Apply the Dark Theme Globally to Wine

In the directory where you downloaded the file, run:

```bash
wine regedit wine-dark-theme.reg
```

---

### Step 3: Apply the Dark Theme to Specific Wine Prefixes (Affinity Apps)
If you’re running Affinity apps (or anything else in a separate Wine prefix), you’ll need to apply the registry file to that specific prefix:

```bash
WINEPREFIX="/path/to/wineprefix/folder" wine regedit wine-dark-theme.reg
```
Replace /path/to/wineprefix/folder with the exact Wine prefix of the app.

---

### TIP: Finding Your Wine Prefix Location

#### _Heroic Games Launcher_
  1. Launch Heroic.
  2. Select an Affinity app.
  3. Under INSTALL INFO, look at the WinePrefix folder path.
  Example:
  ```bash
  WINEPREFIX="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Affinity" wine regedit wine-dark-theme.reg
  ```

#### _Lutris_
  1. Open Lutris and right-click an Affinity app.
  2. Choose Configure → under the Game options tab check the Wine prefix field.
  Example:
  ```bash
  WINEPREFIX="$HOME/.var/app/net.lutris.Lutris/data/bottles/bottles/Affinity" wine regedit wine-dark-theme.reg
  ```

#### _Bottles_
  If you are using Bottles directly, just use the Wine prefix folder configured for your Affinity app:
  Example:
  ```bash
  WINEPREFIX="/path/to/your/bottle" wine regedit wine-dark-theme.reg
  ```
