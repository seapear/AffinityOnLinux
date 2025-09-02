# How to Set Up Wine for Affinity on Bottles

<img src="/Assets/NewLogos/AffinityBottles.png" width="400"/>

## 1. Install Bottles (Flatpak recommended)

Install Bottles using either **Flatpak** or **AppImage**.

- Flatpak: https://flathub.org/apps/com.usebottles.bottles
- AppImage: https://github.com/ivan-hc/Bottles-appimage/releases

## 2. Install Desired Wine Version (ElementalWarrior recommended)

Choose one of the following Wine versions:

- [ElementalWarrior](https://github.com/Twig6943/wine/releases) (Recommended) (Just right click and extract)

- [**Wine-TKG-Affinity**](https://github.com/daegalus/wine-tkg-affinity/releases)  (You're supposed to extract the usr folder inside the  and then rename it to `wine-tkg-affinity-x86_64` )

## 3. Copy & paste Wine Binaries

Copy & paste the wine binaries you've extracted earlier to Bottles’ runners directory:

- **Flatpak:** `~/.var/app/com.usebottles.bottles/data/bottles/runners`
- **AppImage:** `~/.local/share/bottles/runners`

## 4. Add Bottle in Bottles

1. Open Bottles and click on the plus icon.
2. Set the enviroment to Custom.
3. Import the configuration file for your wine fork

- [ElementalWarrior](/Guides/Bottles/InstallScripts/Affinity-ew.yaml)
- [Wine-tkg-affinity](/Guides/Bottles/InstallScripts/Affinity-tkg.yaml)

4. Set the runner to **ElementalWarriorWine** or **wine-tkg-affinity**
5. Click **Create**.

## 5. Extract WinMetadata

1. Unzip the `WinMetadata` folder from the [WinMetadata.zip file](https://archive.org/download/win-metadata/WinMetadata.zip) into `drive_c/windows/system32`

Affinity Apps should now be working inside that bottle.

## Optional: Enable Dark Theme

To enable the dark theme, run [this registry file](https://raw.githubusercontent.com/Twig6943/AffinityOnLinux/refs/heads/main/wine-dark-theme.reg) inside the Wine prefix.
