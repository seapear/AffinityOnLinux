# How to Set Up Wine for Affinity on Lutris

Currently, Lutris is the best method for Nvidia GPU users.

<img src="/Assets/NewLogos/AffinityLutris.png" width="400"/>

Before doing anything, make sure you have a `.exe` version of Affinity Photo, Affinity Designer, and/or Affinity Publisher downloaded from their website: https://store.serif.com/en-us/account/downloads

## 1. Install winetricks

Make sure you have the following programs installed in your Linux system before proceeding:

- [winetricks](https://github.com/Winetricks/winetricks)

`winetricks` is available in the package repositories of major Linux distributions, and can be installed by running commands in the terminal.

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

## 2. Install Lutris

The [Flatpak version](https://flathub.org/apps/net.lutris.Lutris) of Lutris is recommended.

Alternately, you can visit the [download page of Lutris' official website](https://lutris.net/downloads) and follow the instructions to download and install it, or you may install the [unofficial AppImage](https://github.com/pkgforge-dev/Lutris-AppImage) of Lutris using a program such as [GearLever](https://github.com/mijorus/gearlever).

## 3. Download and extract a Wine fork

Choose one of the following forks of Wine, and download and extract it: 

- [**ElementalWarriorWine**](https://github.com/Twig6943/wine/releases) (Recommended) — Download `ElementalWarriorWine-x86_64.tar.gz`, then right click and extract it. You should have a folder now called `ElementalWarriorWine-x86_64` which we'll copy in the next step.

- [**Wine-TKG-affinity**](https://github.com/daegalus/wine-tkg-affinity/releases) — Download the ` wine-tkg-affinity-archbuilt.tar.zst` archive file, then extract the `usr/` folder from the archive and rename the folder to `wine-tkg-affinity-x86_64`.

## 4. Copy and paste Wine fork to Lutris' system directory

Lutris' Wine-related folders can be found in a hidden directory within your `home` folder. If you can't see hidden folders in your file browser, you can usually enable them by pressing `Ctrl + H`

- If you installed Lutris via **Flatpak**, navigate to `/home/[your-username]/.var/app/net.lutris.Lutris/data/lutris/runners/`
- If you installed Lutris via **AppImage** or other methods, navigate to `/home/[your-username]/.local/share/lutris/runners/`

Create a folder called `wine` if one does not already exist, then copy and paste the folder you extracted in the previous step to this folder.

This is also known as your "Wine runner."

## 5. Install Affinity with Lutris

1. Download the install script for your Wine fork — visit one of the following links based on your choice of Wine fork, then click the download button located on the top right of the file content to download it as a `.yaml` install script file:
    - [ElementalWarrior](/Guides/Lutris/InstallScripts/Affinity-ew.yaml) `Affinity-ew.yaml`
    - [Wine-tkg-affinity](/Guides/Lutris/InstallScripts/Affinity-tkg.yaml) `Affinity-tkg.yaml`
2. Open Lutris and click on the plus `+` icon on the top left corner of the window.
3. Press "Install from a local install script".
4. Press on the `⋮` three vertical dots button, then select the `.yaml` install script file you just downloaded for your Wine fork
5. Press `Install`, then press `Install` again
6. Select or create a filepath for where you would like everything to install, such as `/home/[your-username]/AffinityOnLinux`
7. Check [✓] `Create desktop shortcut` and/or [✓] `Create application menu shortcut`, then press `Continue`
8. Select Affinity's setup file by pressing on the `⋮` three vertical dots button then choosing the `.exe` for Affinity Photo, Affinity Designer, or Affinity Publisher
9. Press `Install`.

At this point, you may get a message saying "Wine could not find a wine-mono package...". Go ahead and click `Install`.

You will see a bunch of code running in a terminal-like space. This may take several minutes.

10. Once the terminal stuff is done, an Affinity window should pop up with a button to `Install`. Let it install, then once it's done click `Close`.
11. Click `Launch` - you will now see an error message from Lutris that says 'This game has no executable set. The install process didn't finish properly.' Just click `OK` - we will address this in the next step.

(Congrats on making it this far!) 🐧

## 6. Get ready to launch

At this point, you should be in the 🎮 Games section of Lutris where a blank rectangle labeled `Affinity Suite` should exist. Right click on it and select `Configure` (should be the third option down).

2. Under the first tab, `Game info`, change the `Name` field from Affinity Suite to the name of the app you just installed (Affinity Photo, Affinity Designer, or Affinity Publisher)

3. Next to the the `Identifier` field (towards the bottom), press `Change` then type in the correlated app name in lowercase and dashes, then press `Apply` to apply the change: 
    * `affinity-photo`
    * `affinity-designer`
    * `affinity-publisher`
  
4. You can find icons, cover art and banners for Affinity apps in AffinityOnLinux's [`Icons`](/Assets/Icons) and [`Covers`](/Assets/Covers) folders.

3. Switch to the `Game options` tab. 
4. In the **`Executable`** field, copy and paste one of the following:

   Affinity Photo:
      ```shell
      drive_c/Program Files/Affinity/Photo 2/Photo.exe
      ```
   Affinity Designer:
      ```shell
      drive_c/Program Files/Affinity/Designer 2/Designer.exe
      ```
   Affinity Publisher:
      ```shell
      drive_c/Program Files/Affinity/Publisher 2/Publisher.exe
      ```

5. Click `Save`
6. Press `Play` to launch the app

At this point, you may wish to install other Affinity apps, fix scaling issues for high resolution screens, or enable a dark theme for Wine. If any of these apply to you, keep reading:

### Installing other Affinity apps

After installing one Affinity app using the steps above, you can install the others to the same Wine prefix as follows:

1. Select an existing Affinity app in Lutris.
2. Open the `^` Wine menu at the bottom of the Lutris window, then click `Run EXE inside Wine prefix`.
3. Run the installer for another Affinity app.
4. Right click the Affinity app you have installed first and select `Duplicate` from the menu.
5. Right click the duplicated Affinity app and select `Configure` from the menu.
5. Edit the `Name` and `Identifier` fields under the `Game Info` tab.
6. Set the correct `.exe` under the `Game Options` tab.

### Fixing Scaling on HiDPI Screens

To adjust the scaling of Affinity apps' UI on high resolution monitors, follow these steps:

1. Launch Lutris.
2. Select one of the Affinity apps you have installed.
3. Open the `^` Wine menu at the bottom of the Lutris window, and select `Wine configuration`.
4. Go to the `Graphics` tab.
5. Under the `Screen resolution` section, increase the `dpi` value until the sample text appears large enough.

Note that these Wine configuration settings will apply to all Affinity apps you installed with Lutris, since they share the same Wine prefix.

### Dark Theme for Wine

To enable the dark theme for Wine, follow these steps:

1. Click [here](/Auxillary/Other/wine-dark-theme.reg) to download a `.reg` file by clicking the download button on the top right just like we did for the `.yaml` file earlier
2. Save the file to your Downloads folder
3. Open Terminal, then type `cd Downloads` to change to your Downloads folder
4. Run the following command:
    ```shell
    wine regedit wine-dark-theme.reg
    ```
5. Press `Enter`. You might get a message again saying "Wine could not find a wine-mono package...". Just click `Install`.
6. Launch Lutris, then right click on any Affinity app and select `Configure` from the menu
7. Under the `Game options` tab, copy the filepath from the **`Wine prefix`** field
8. Run the following command, replacing `/path/to/wineprefix` with the filepath you just copied
   ```shell
   WINEPREFIX="/path/to/wineprefix" wine regedit wine-dark-theme.reg
   ```
