# Installing Affinity on Linux with the AffinityOnLinux Script

## Step-by-Step Installation Guide

### Step 1: Download Afiinity

Download `Affinity.msix` or `Affinity.exe` from the [download page of Affinity's official website](https://www.affinity.studio/download). From the "Download for Windows" drop-down menu, select "Windows (Intel/AMD)" to download `Affinity.msix`, or "Enterprise (Intel/AMD)" to download `Affinity.exe`.

### Step 2: Download Affinity On Linux Installer Scripts

Visit the following files from this repository's [script installer directory](/Guides/Wine/Script%20Installer), then click the download button located on the top right of the file content to download the files:

- [`AoL_ScriptInstaller-GameDirection.sh`](/Guides/Wine/Script%20Installer/AoL_ScriptInstaller-GameDirection.sh)
- [`affinity_installer_unified.py`](/Guides/Wine/Script%20Installer/affinity_installer_unified.py)
Make sure you have both `AoL_ScriptInstaller-GameDirection.sh` *and* `affinity_installer_unified.py` files in the same directory before running the installer.

### Step 3: Grant Executable Permissions to Installer Script

Run the command `chmod +x ./*.sh` to grant executable permissions to the `AoL_ScriptInstaller-GameDirection.sh` shell script in the current directory.

### Step 4: Run the Installer Script

Execute the `AoL_ScriptInstaller-GameDirection.sh` shell script. Follow the prompts to complete the installation process.

> [!NOTE]
> The dotnet48 installation may take some time and appear to hang. Please be patient, as it's a crucial step in setting up Affinity on your Linux system.

## Post-Installation

Once the installation is complete, you should find a `.desktop` file created in the same directory. This file will allow you to easily launch Affinity from your desktop environment or file manager.

## Tips and Troubleshooting

* If the dotnet48 installation seems stuck, try checking the installation progress periodically. It may take some time to complete.
* If you encounter any issues during the installation process, please refer to the AffinityOnLinux documentation or seek assistance from the community in the [AffinityOnLinux Discord server](https://join.affinityonlinux.com/). Please provide a your log to help identify any fail points. 
* Please use `neofetch` or [`fastfetch`](https://github.com/fastfetch-cli/fastfetch) as they are great tools to help the community troubleshoot.

## Get Started with Affinity on Linux

With your successful installation of Affinity on Linux using the AffinityOnLinux script, you're now ready to unleash your creative potential and enjoy a seamless experience.
