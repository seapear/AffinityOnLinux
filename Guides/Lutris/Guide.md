# How to Set Up Wine for Affinity on Lutris

Currently, Lutris is the best method for Nvidia GPU users.

<img src="/Assets/NewLogos/AffinityLutris.png" width="400"/>


## 1. Install Lutris (Flatpak recommended)

Install Lutris using either **Flatpak** or **AppImage**.

- Flatpak: https://flathub.org/apps/net.lutris.Lutris
- AppImage: https://github.com/pkgforge-dev/Lutris-AppImage

## 2. Install Wine version of your choice

- [**ElementalWarriorWine**](https://github.com/Twig6943/wine/releases) (Recommended) (Just right click and extract)

- [**Wine-TKG-affinity**](https://github.com/daegalus/wine-tkg-affinity/releases) (extract the `usr/` folder inside the archive and rename it to `wine-tkg-affinity-x86_64`)

## 3. Copy & paste Wine Binaries

Copy & paste the previously extracted folder to the Lutris runners directory:

- **Flatpak:** `~/.var/app/net.lutris.Lutris/data/lutris/runners/wine/`
- **AppImage:** `~/.local/share/lutris/runners/wine/` 

## 4. Add Affinity to Lutris

1. Open Lutris and click on the plus icon.
2. Install from a local install script.
3. Import the configuration file for your wine fork.

- [ElementalWarrior](/Guides/Lutris/InstallScripts/Affinity-ew.yaml)
- [Wine-tkg-affinity](/Guides/Lutris/InstallScripts/Affinity-tkg.yaml)

4. Press `Install`
5. Select the affinity setup `.exe`
6. Press `Install`

## 5. Configure the Executable Path

Once the install finishes, right click the Affinity entry in Lutris and choose `Configure`.

1. Navigate to `Game Info`.
2. Change the name field to the correlated app name: 

    * `Affinity Photo` 
    * `Affinity Designer`
    * `Affinity Publisher`

3. Select `Game Options` 
4. Change the executable to one of the following:

    * `drive_c/Program Files/Affinity/Photo 2/Photo.exe`
    * `drive_c/Program Files/Affinity/Designer 2/Designer.exe`
    * `drive_c/Program Files/Affinity/Publisher 2/Publisher.exe`

5. Click `Save` & launch the app.

## Optional: Installing Other Apps to the Same Prefix

After installing one app using the steps above, you can install the others to the same prefix as follows:
1. Select existing Affinity app.
2. Click `Run EXE inside Wine prefix` in the Wine dropdown (bottom of window).
3. Run the installer for the other Affinity app.
4. Right click the app you've installed first and choose Duplicate.
5. Edit the name under `Configure > Game Info` 
6. Set the correct `.exe` under `Configure > Game Options`.
