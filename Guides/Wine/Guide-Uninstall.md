# Complete Wine Uninstallation/Purge Guide

## Overview
This guide provides a comprehensive method for removing Wine and all associated components from your Linux system.

>[!Warning]
> - **Backup Important Data**: Ensure you've backed up any important Windows applications or data stored in your Wine prefixes before proceeding
> - **Custom Installations**: If you installed Wine from source or using alternative methods, additional cleanup may be required
> - **System Variations**: Some directory paths may vary depending on your Linux distribution and Wine installation method

## Step-by-Step Uninstallation

### 1. Remove Wine Packages
```bash
sudo apt purge --autoremove wine* winetricks -y
```

### 2. Remove WineHQ Repository Sources
```bash
sudo rm -f /etc/apt/sources.list.d/winehq.list
```

### 3. Remove WineHQ GPG Keys
```bash
sudo rm -f /etc/apt/keyrings/winehq.asc
```

### 4. Update Package Lists
```bash
sudo apt update
```

### 5. Remove User Wine Data and Configurations
```bash
rm -rf ~/.wine
rm -rf ~/.local/share/applications/wine
rm -rf ~/.cache/wine
rm -rf ~/.config/wine
rm -rf ~/.affinity
```

**Note:** The `.affinity` directory removal is specific to Affinity software installations through Wine and may not be present on all setups.

### 6. Remove Winetricks (if installed manually)
```bash
sudo rm -f /usr/local/bin/winetricks
```

### 7. Final System Cleanup
```bash
sudo apt autoremove -y
sudo apt clean
```

## Verification

After completing these steps, verify Wine is completely removed by running:
```bash
which wine
wine --version
```
Both commands should return no results or "command not found" errors.


> [!NOTE]
> ## Troubleshooting
> 
> If you encounter issues:
> - Check for remaining Wine-related packages: `dpkg -l | grep wine`
> - Search for leftover Wine files: `locate wine | grep -v /proc`
> - Review package manager logs for any installation anomalies

This process should completely remove Wine and its associated components from your system.
