# How to Set Up Wine for Affinity on Lutris

Currently, Lutris is the best method for Nvidia GPU users.

<img src="/Assets/NewLogos/AffinityLutris.png" width="400"/>

## Dependencies 

Make sure you have the following programs installed in your Linux system before proceeding:

- [winetricks](https://github.com/Winetricks/winetricks)

The dependencies are available in the package repositories of major Linux distributions, and can be installed by running commands in the terminal.

For Debian- or Ubuntu-based distros, run the command:
```shell
sudo apt install winetricks
```

For Fedora Linux-based distros, run the command:
```shell
sudo dnf install winetricks
```

For Arch Linux-based distros, run the command:
```shell
sudo pacman -Sy winetricks
```

## 1. Install Lutris

Visit the [download page of Lutris' official website](https://lutris.net/downloads), and follow the instructions to download and install Lutris. [Flatpak](https://flathub.org/apps/net.lutris.Lutris) is recommended.

Alternately, you may install Lutris using the [unofficial AppImage](https://github.com/pkgforge-dev/Lutris-AppImage).

## 2. Download and Extract a Wine Fork

Choose one of the following forks of Wine, and download and extract it: 

- [**ElementalWarriorWine**](https://github.com/Twig6943/wine/releases) (Recommended) — After downloading the `ElementalWarriorWine-x86_64.tar.gz` archive file, right click and extract the archive into an `ElementalWarriorWine-x86_64` folder.

- [**Wine-TKG-affinity**](https://github.com/daegalus/wine-tkg-affinity/releases) — Download the ` wine-tkg-affinity-archbuilt.tar.zst` archive file, then extract the `usr/` folder from the archive and rename the folder to `wine-tkg-affinity-x86_64`.

## 3. Copy and Paste Wine Fork Binaries to Lutris

Copy and paste the extracted Wine fork folder from the previous step to the Lutris runners' Wine directory:

- **Flatpak:** `~/.var/app/net.lutris.Lutris/data/lutris/runners/wine/`
- **Other Install Mehtods:** `~/.local/share/lutris/runners/wine/` 

If there is no `wine` folder inside your Lutris runners directory, create it, then copy and paste your Wine fork folder into the `wine` folder.

## 4. Install Affinity with Lutris

1. Open Lutris and click on the plus icon on the top left corner of the window.
2. Press "Install from a local install script".
3. Download the install script for your Wine fork — Visit one of the following links based on your choice of Wine fork, then click the download button located on the top right of the file content to download the install script file, which is in YAML format.
    - [ElementalWarrior](https://raw.githubusercontent.com/helenclx/AffinityOnLinux/refs/heads/main/Guides/Lutris/InstallScripts/Affinity-ew.yaml)
    - [Wine-tkg-affinity](/Guides/Lutris/InstallScripts/Affinity-tkg.yaml)

4. In Lutris, import the install script file for your Wine fork.
7. Press `Install`.
6. Select the setup `.exe` file of an Affinity app (Photo, Designer or Publisher).
7. Press `Install`.

## 5. Configure the Executable Path

Once the install of the Affinity app finishes, right click the Affinity app entry in Lutris and select `Configure` from the menu.

1. Navigate to the `Game Info` tab.
2. Change the `Name` field to the correlated app name: 

    * `Affinity Photo` 
    * `Affinity Designer`
    * `Affinity Publisher`

3. (Recommended) Change the `Identifier` field to the correlated app name in lowercase and dashes:

    * `affinity-photo`
    * `affinity-designer`
    * `affinity-publisher`

3. Switch to the `Game options` tab. 
4. Change the executable to one of the following:

    * `drive_c/Program Files/Affinity/Photo 2/Photo.exe`
    * `drive_c/Program Files/Affinity/Designer 2/Designer.exe`
    * `drive_c/Program Files/Affinity/Publisher 2/Publisher.exe`

5. Click `Save` & launch the app.

## Optional: Installing Other Apps to the Same Prefix

After installing one Affinity app using the steps above, you can install the others to the same Wine prefix as follows:

1. Select an existing Affinity app in Lutris.
2. Open the Wine menu at the bottom of the Lutris window, then click `Run EXE inside Wine prefix`.
3. Run the installer for another Affinity app.
4. Right click the Affinity app you have installed first and select `Duplicate` from the menu.
5. Right click the duplicated Affinity app and select `Configure` from the menu.
5. Edit the `Name` and `Identifier` fields under the `Game Info` tab.
6. Set the correct `.exe` under the `Game Options` tab.

## Optional: Set Icon, Cover Art and Banner for Affinity in Lutris

After installing an Affinity app with Lutris, you can set the icon, cover art and banner for the Affinity app.

1. Right click an Affinity app entry, then select `Configure`.
2. Under the `Game info` tab, set custom icon, cover art and banner.

You can find icons, cover art and banner for Affinity apps from the AffinityOnLinux repository's [`Assets/Icons`](/Assets/Icons) and [`Assets/Covers`](/Assets/Covers) directories.

Make sure the `Identifier` has been changed to the corresponding name of each different Affinity app, as instructed the above steps to configure your Affinity apps' executable paths, otherwise Lutris will make the icons and cover art the same across all the different Affinity apps.

## Additional Tips and Tricks

### Fixing Scaling on HiDPI Screens

To adjust the scaling of Affinity apps' UI on high resolution monitors, follow these steps:

1. Launch Lutris.
2. Select one of the Affinity apps you have installed.
3. Open the WIne menu at the bottom of the Lutris window, and select `Wine configuration`.
4. Go to the `Graphics` tab.
5. Under the `Screen resolution` section, increase the `dpi` value to your preference.

Note that these Wine configuration settings will apply to all Affinity apps you installed with Lutris, since they share the same Wine prefix.

### Dark Theme for Wine

To enable the dark theme for Wine, follow these steps:

1. Visit the [wine-dark-theme registry file](/Auxillary/Other/wine-dark-theme.reg) from this repository, and download the file by clicking the download button on the top right.
2. In the folder where you downloaded the registry file into, run the following command:
   ```shell
   wine regedit wine-dark-theme.reg
   ```
3. If you also want to enable dark theme for the Wine fork for your installed Affinity apps on Lutris, run the command:
    ```shell
   WINEPREFIX="/path/to/wineprefix" wine regedit wine-dark-theme.reg
   ```
   - To check your Affinity app's Wine prefix, launch Lutris, then right click on an Affinity app, and select `Configure` from the menu. Under the `Game options` tab, check the `Wine prefix` field.
   - Replace `/path/to/wineprefix` in the command above with the Wine prefix of your installed Affinity app.
