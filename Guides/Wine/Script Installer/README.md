# Installing Affinity on Linux with the AffinityOnLinux Script
## Prerequisites

* Make sure you have both `Affinity.msix` and `Affinity.exe` files in the same directory.

## Step-by-Step Installation Guide

### 1. Download and Extract the Files

Download the `Affinity.msix` or `Affinity.exe`.

Download the .sh and .py file from the script installer directory https://github.com/seapear/AffinityOnLinux/tree/main/Guides/Wine/Script%20Installer

### 2. Grant Executable Permissions

Run the command `chmod +x ./*.sh` to grant executable permissions to all shell scripts (.sh) in the current directory.

### 3. Run the Installer Script

Execute the script by running one of the `.sh` installers (e.g., `AoL_ScriptInstaller-GameDirection.sh`). Follow the prompts to complete the installation process.

### Note

The dotnet48 installation may take some time and appear to hang. Please be patient, as it's a crucial step in setting up Affinity on your Linux system.

## Post-Installation

Once the installation is complete, you should find a `.desktop` file created in the same directory. This file will allow you to easily launch Affinity from your desktop environment or file manager.

## Tips and Troubleshooting

* Make sure you have both `AoL_ScriptInstaller-GameDirection.sh` or `affinity_installer_unified.py` files in the same directory before running the installer.
* If the dotnet48 installation seems stuck, try checking the installation progress periodically. It may take some time to complete.
* If you encounter any issues during the installation process, please refer to the AffinityOnLinux documentation or seek assistance from the community in the discord. Please provide a your log to help identify any fail points. 
* Please use `Neofetch`/`Fastfetch` as they are great tools to help the community troubleshoot.

## Get Started with Affinity on Linux

With your successful installation of Affinity on Linux using the AffinityOnLinux script, you're now ready to unleash your creative potential and enjoy a seamless experience.
