# How to Set Up Wine for Affinity on Bottles

<img src="/Assets/NewLogos/AffinityBottles.png" width="400"/>

## 1. Install Bottles

Visit the [download page of Bottles' official website](https://usebottles.com/download/), and follow the instructions to download and install Bottles. [Flatpak](https://flathub.org/apps/com.usebottles.bottles) is recommended, as it is the only officially supported install method for Bottles.

Alternately, you may want to install Bottles using the [unofficial AppImage](https://github.com/ivan-hc/Bottles-appimage).

## 2. Download and Extract a Wine Fork

Choose one of the following forks of Wine, and download and extract it: 

- [**ElementalWarriorWine**](https://github.com/Twig6943/wine/releases) (Recommended) — After downloading the `ElementalWarriorWine-x86_64.tar.gz` archive file, right click and extract the archive into an `ElementalWarriorWine-x86_64` folder.

- [**Wine-TKG-affinity**](https://github.com/daegalus/wine-tkg-affinity/releases) — Download the ` wine-tkg-affinity-archbuilt.tar.zst` archive file, then extract the `usr/` folder from the archive and rename the folder to `wine-tkg-affinity-x86_64`.

## 3. Copy and Paste Wine Fork Binaries to Bottles 

Copy and paste the extracted Wine fork folder from the previous step to Bottles' runners directory:

- **Flatpak:** `~/.var/app/com.usebottles.bottles/data/bottles/runners`
- **AppImage:** `~/.local/share/bottles/runners`

## 4. Add Bottle in Bottles

1. Open Bottles and click on the plus icon.
2. Name it "Affinity" or "Serif".
3. Set the enviroment to Custom.
4. Keep Architecture -> `64bit`
5. Set the runner to **ElementalWarriorWine** or **wine-tkg-affinity**, depending on your choice of Wine fork.
6. Download the install script file for your Wine fork — Visit one of the following links based on your choice of Wine fork, then click the download button located on the top right of the file content to download the install script file, which is in YAML format.
   - [ElementalWarrior](/Guides/Bottles/InstallScripts/Affinity-ew.yaml)
   - [Wine-tkg-affinity](/Guides/Bottles/InstallScripts/Affinity-tkg.yaml)
7. In Bottles, import the install script file for your Wine fork. `Import Configuration -> Affinity-ew.yaml`
8. Click **Create**.

<img height="350" alt="image" src="https://github.com/user-attachments/assets/f17de84b-859a-49a2-8d01-09da643a2fbf" />

## 5. Extract WinMetadata

1. Download the [`WinMetadata.zip` archive file](https://archive.org/download/win-metadata/WinMetadata.zip).
2. Extract the `WinMetadata` folder from the archive into `drive_c/windows/system32`.

The Affinity app should now work inside that Bottle.

## Additional Tips and Tricks

### Common Location

The Affinity apps installed with Bottles are located at the following location:

- **Flatpak**: `~/.var/app/com.usebottles.bottles/data/bottles/bottles/Affinity/drive_c`

### How to Fix Studdering
- Bottles -> Settings -> # Performance | Toggle on Feral GameMode
- Bottles -> Settings -> # Compatibility | Windows 10 -> Windows 11 [*](https://discord.com/channels/1281706644073611358/1289640098589315174/1418124555406544956)

### Dark Theme for Wine

To enable the dark theme for Wine, run [this registry file](/wine-dark-theme.reg) inside the Wine prefix.
