# How to Set Up Wine for Affinity on Bottles

<img src="/Assets/NewLogos/AffinityBottles.png" width="400"/>

Before doing anything, make sure you have a `.exe` version of Affinity apps. You can download Affinity apps from the official Affinity websites:

- [Affinity by Canva](https://www.affinity.studio/download)
- [Affinity Photo V2](https://store.serif.com/update/windows/photo/2/) 
- [Affinity Designer V2](https://store.serif.com/update/windows/designer/2/)
- [Affinity Publisher V2](https://store.serif.com/update/windows/publisher/2/) 
- [Affinity Photo V1](https://store.serif.com/update/windows/photo/1/)
- [Affinity Designer V1](https://store.serif.com/update/windows/designer/1/)
- [Affinity Publisher V1](https://store.serif.com/update/windows/publisher/1/)

## 1. Install Bottles

Visit the [download page of Bottles' official website](https://usebottles.com/download/), and follow the instructions to download and install Bottles. [Flatpak](https://flathub.org/apps/com.usebottles.bottles) is recommended, as it is the only officially supported install method for Bottles.

Alternately, you may want to install Bottles using the [unofficial AppImage](https://github.com/ivan-hc/Bottles-appimage).

## 2. Download Wine 10.17 staging runner

1. Open Bottles and click on the hamburger/3 dots menu button
2. Go to Preferences
3. Got to Runners tab
4. Unfold the kron4ek section and download the last wine version (staging and tkg doesn't matter from my testing)

## 3. Add Bottle in Bottles

1. Open Bottles and click on the plus icon.
2. Name it "Affinity" or "Serif".
3. Set the environment to Custom.
4. Keep Architecture -> `64bit`
5. Set the runner to **kron4ek-wine-<version>-amd64**
6. Download the install script file
7. In Bottles, import the install script file for your Wine fork. `Import Configuration -> Affinity-nu.yaml`
8. Click **Create**.

<img height="350" alt="image" src="https://github.com/user-attachments/assets/f17de84b-859a-49a2-8d01-09da643a2fbf" />
<img width="1108" height="884" alt="bottle_creation_window" src="https://github.com/user-attachments/assets/ffd4641b-66a9-4bc7-8718-ef64b937e0fc" />


## 5. Add Windows.winmd

1. Download the [`Windows.winmd` file](https://github.com/microsoft/windows-rs/raw/refs/heads/master/crates/libs/bindgen/default/Windows.winmd).
2. Insert the `Windows.winmd` file you downloaded into `drive_c/windows/system32/winmetadata`.

The Affinity app should now work inside that Bottle.

## Additional Tips and Tricks

### Common Location

The Affinity apps installed with Bottles are located at the following location:

- **Flatpak**: `~/.var/app/com.usebottles.bottles/data/bottles/bottles/Affinity/drive_c`

### How to Fix Studdering

- Bottles -> Settings -> # Performance | Toggle on Feral GameMode
- Bottles -> Settings -> # Compatibility | Windows 10 -> Windows 11 [*](https://discord.com/channels/1281706644073611358/1289640098589315174/1418124555406544956)
### Dark Theme for Wine

1. Visit the [wine-dark-theme registry file](/Auxiliary/Other/wine-dark-theme.reg) from this repository, and download the file by clicking the download button on the top right.
2. In the folder where you downloaded the registry file into, run the following command:
   ```shell
   wine regedit wine-dark-theme.reg
   ```
3. If you also want to enable dark theme for the Wine fork for your installed Affinity apps on Bottles, run the command:
    ```shell
   WINEPREFIX="$HOME/.var/app/com.usebottles.bottles/data/bottles/bottles/Affinity" wine regedit wine-dark-theme.reg
   ```
