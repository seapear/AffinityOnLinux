# Settings

Affinity apps sometimes tend not to save settings properly. There are two methods of fixing this. Given a `wineprefix` of `drive_c/users/$USERNAME/AppData/Roaming/Affinity/`:

1. Clone this repository and copy the files from [./Auxiliary/](../Auxiliary/Settings) to their respective paths inside the `wineprefix`.
2. Locate the settings folders on a windows machine and paste them into the
   corresponding locations in the `wineprefix`.

## Method 1 - AffinityPluginLoader (Recommended Method)

### Install Affinity Plugin Loader + WineFix  
> **Author:** [Noah C3](https://github.com/noahc3)  
> **Project:** [AffinityPluginLoader + WineFix](https://github.com/noahc3/AffinityPluginLoader/)  
> *This patch is community‑made and **not official**, but it greatly improves runtime stability and fixes the “Preferences not saving” issue on Linux.*

### Purpose
- Provides plugin loading and dynamic patch injection via **Harmony**  
- Restores **on‑the‑fly settings saving** under Wine  
- Temporarily skips the Canva sign‑in dialog (until the browser redirect fix is ready)

---

### Installation
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

> *Now your existing launchers still work, `wine .../Affinity.exe` automatically loads AffinityPluginLoader & WineFix.*

### 🧪 Verify
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

## Method 2

This method is tested and working for the recommended [Lutris/EW](../Guides/Lutris/Guide.md) install. 

Clone the repository and move into the source directory:
```sh
git clone git@github.com:seapear/AffinityOnLinux.git
cd AffinityOnLinux/Auxiliary/Settings/
```

Execute the following code for each app, each time replacing `$APP` with the name of the
target Affinity application and `$USERNAME` with the name of the user. 

```sh
mv $APP/2.0/Settings drive_c/users/$USERNAME/AppData/Roaming/Affinity/
```

## Method 3

Copy the respective settings folders from `C:\\\users\$USERNAME\AppData\Roaming\Affinity\$APP\$VERSION\Settings\` on windows into the corresponding directory inside the `wineprefix`.

For example:

```sh
C:\\\users\$USERNAME\AppData\Roaming\Affinity\Designer\2.0\Settings\ -> drive_c/users/$USERNAME/AppData/Roaming/Affinity/Designer/2.0/

C:\\\users\$USERNAME\AppData\Roaming\Affinity\Photo\2.0\Settings\ -> drive_c/users/$USERNAME/AppData/Roaming/Affinity/Photo/2.0/

C:\\\users\$USERNAME\AppData\Roaming\Affinity\Publisher\2.0\Settings\ -> drive_c/users/$USERNAME/AppData/Roaming/Affinity/Designer/2.0/
```

## Editing The Settings Files

The settings files use the `.xml` format and can be modified using a text editor.
