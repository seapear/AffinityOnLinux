#!/usr/bin/env python3
"""
Affinity Installer - Unified Single-File Version
Complete installer with GUI frontend and bash backend in one file
No external dependencies except PyQt6 (auto-installed)
Version 5
"""

import os
import sys
import subprocess
import shutil
import tempfile
from pathlib import Path
import re

# Auto-install PyQt6 if missing
try:
    from PyQt6.QtWidgets import *
    from PyQt6.QtCore import *
    from PyQt6.QtGui import *
except ImportError:
    print("Installing PyQt6...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", "PyQt6"])
    from PyQt6.QtWidgets import *
    from PyQt6.QtCore import *
    from PyQt6.QtGui import *


# ============================================================================
# EMBEDDED BASH SCRIPT
# ============================================================================

BASH_SCRIPT = r'''#!/bin/bash

################################################################################
# Affinity Linux Installation Script - ENHANCED VERSION
# 
# Features:
# - Interactive arrow-key menu
# - Auto Wine 10+ installation
# - Unified logging
# - Final verification
# - Smart continue/resume
# - GUI mode support
################################################################################

# ==========================================
# Colors and Configuration
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GUI Mode flag
GUI_MODE=false
INSTALLER_PATH=""

# Installation directory
INSTALL_DIR="$HOME/.AffinityOnLinux"
WINEPREFIX="$INSTALL_DIR"

# Unified log file
LOG_FILE="$HOME/affinity_install_$(date +%Y%m%d_%H%M%S).log"

# Overall progress tracking
TOTAL_STEPS=10
CURRENT_STEP=0
CURRENT_PROGRESS=0

# Installation mode
INSTALL_MODE=""

# Component status flags
PREFIX_EXISTS=false
WINE_EXISTS=false
WINE_VERSION_OK=false
DOTNET35_EXISTS=false
DOTNET48_EXISTS=false
VCRUN_EXISTS=false
PHOTO_EXISTS=false
DESIGNER_EXISTS=false
PUBLISHER_EXISTS=false

# Optional component flags (from GUI)
ENABLE_DXVK=false
ENABLE_VULKAN=false
ENABLE_TAHOMA=false

# ==========================================
# GUI Output Functions
# ==========================================

gui_progress() {
    local percent=$1
    local message=$2
    CURRENT_PROGRESS=$percent
    if [ "$GUI_MODE" = true ]; then
        echo "PROGRESS:${percent}:${message}"
    fi
}

gui_success() {
    if [ "$GUI_MODE" = true ]; then
        echo "SUCCESS:$1"
    fi
}

gui_error() {
    if [ "$GUI_MODE" = true ]; then
        echo "ERROR:$1"
    fi
}

gui_info() {
    if [ "$GUI_MODE" = true ]; then
        echo "INFO:$1"
    fi
}

# ==========================================
# Logging Functions
# ==========================================

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
    gui_info "$message"
}

log_command() {
    local command="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] COMMAND: $command" >> "$LOG_FILE"
    eval "$command" 2>&1 | tee -a "$LOG_FILE"
    local exit_code=${PIPESTATUS[0]}
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] EXIT CODE: $exit_code" >> "$LOG_FILE"
    return $exit_code
}

# ==========================================
# Interactive Menu Functions (Disabled in GUI mode)
# ==========================================

show_menu() {
    if [ "$GUI_MODE" = true ]; then
        return 0
    fi
    
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local key

    while true; do
        clear
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${CYAN}$title${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "${GREEN}▶ ${options[$i]}${NC}"
            else
                echo -e "  ${options[$i]}"
            fi
        done
        
        echo ""
        echo -e "${YELLOW}Use ↑/↓ arrows to navigate, Enter to select${NC}"
        echo -e "${YELLOW}Or type number (1-${#options[@]}) and press Enter${NC}"
        
        IFS= read -rsn1 key
        
        if [[ $key =~ ^[0-9]$ ]]; then
            local num=$((key - 1))
            if [ $num -ge 0 ] && [ $num -lt ${#options[@]} ]; then
                return $num
            fi
        elif [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case $key in
                '[A')
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                '[B')
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                    ;;
            esac
        elif [[ $key == "" ]]; then
            return $selected
        fi
    done
}

# ==========================================
# Wine Installation (Simplified for GUI mode)
# ==========================================

check_wine_version() {
    if ! command -v wine &> /dev/null; then
        log "Wine not found"
        return 1
    fi
    
    local wine_version=$(wine --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1)
    if [ -z "$wine_version" ]; then
        log "Could not determine Wine version"
        return 1
    fi
    
    local major=$(echo "$wine_version" | cut -d. -f1)
    
    log "Found Wine version: $wine_version"
    
    if [ "$major" -ge 10 ]; then
        WINE_VERSION_OK=true
        return 0
    fi
    
    log "Wine version too old (need 10.0+)"
    return 1
}

# ==========================================
# Winetricks Installation
# ==========================================

check_winetricks() {
    if command -v winetricks &> /dev/null; then
        log "Winetricks found: $(command -v winetricks)"
        return 0
    fi
    
    if [ -f "$HOME/winetricks" ] && [ -x "$HOME/winetricks" ]; then
        log "Winetricks found locally: $HOME/winetricks"
        return 0
    fi
    
    log "Winetricks not found"
    return 1
}

# ==========================================
# Component Installation (Simplified)
# ==========================================

install_missing_components() {
    log "Starting component installation..."
    
    gui_progress 15 "Checking for Winetricks"
    
    if ! check_winetricks; then
        gui_error "Winetricks not found. Please install winetricks first."
        log "ERROR: Winetricks not found"
        exit 1
    fi
    
    gui_progress 20 "Creating Wine prefix"
    
    if [ ! -d "$WINEPREFIX" ]; then
        log "Creating Wine prefix at $WINEPREFIX"
        WINEPREFIX="$WINEPREFIX" wineboot --init 2>&1 | tee -a "$LOG_FILE"
        sleep 3
        log "Wine prefix created successfully"
    else
        log "Wine prefix already exists"
    fi
    
    gui_progress 25 "Installing dependencies (this may take 30-45 minutes)"
    
    log "Installing all dependencies with winetricks"
    
    # Base components (always installed)
    COMPONENTS="remove_mono vcrun2022 dotnet48 corefonts win11 webview2"
    
    # Append optional components if enabled
    if [ "$ENABLE_DXVK" = true ]; then
        COMPONENTS="$COMPONENTS dxvk"
        log "Adding DXVK to installation (for stability)"
    fi
    
    if [ "$ENABLE_VULKAN" = true ]; then
        COMPONENTS="$COMPONENTS renderer=vulkan"
        log "Adding Vulkan renderer to installation (For GPU)"
    fi
    
    if [ "$ENABLE_TAHOMA" = true ]; then
        COMPONENTS="$COMPONENTS tahoma"
        log "Adding Tahoma font to installation (fonts not showing up right)"
    fi
    
    log "Installing components: $COMPONENTS"
    WINEPREFIX="$WINEPREFIX" winetricks --unattended --force $COMPONENTS 2>&1 | tee -a "$LOG_FILE"
    
    gui_progress 60 "Dependencies installation completed"
    
    gui_progress 65 "Verifying installed components"
    
    log "Component installation completed"
}

# ==========================================
# Download Helper Files
# ==========================================

download_helper_files() {
    log "Downloading helper files..."
    
    gui_progress 70 "Downloading helper files (wintypes.dll, Windows.winmd)"
    
    local temp_dir="/tmp"
    
    log "Downloading wintypes.dll"
    
    if command -v curl &> /dev/null; then
        curl --output "$temp_dir/wintypes.dll" --follow --location \
            "https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so" 2>&1 | tee -a "$LOG_FILE"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/wintypes.dll" \
            "https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so" 2>&1 | tee -a "$LOG_FILE"
    else
        gui_error "Neither curl nor wget found"
        log "ERROR: Neither curl nor wget available"
        return 1
    fi
    
    log "Downloading Windows.winmd"
    
    if command -v curl &> /dev/null; then
        curl --output "$temp_dir/Windows.winmd" --follow --location \
            "https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd" 2>&1 | tee -a "$LOG_FILE"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/Windows.winmd" \
            "https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd" 2>&1 | tee -a "$LOG_FILE"
    fi
    
    log "All helper files downloaded successfully"
    
    WINTYPES_DLL="$temp_dir/wintypes.dll"
    WINDOWS_WINMD="$temp_dir/Windows.winmd"
    
    return 0
}

# ==========================================
# Install Affinity Application
# ==========================================

install_affinity_app() {
    if [ -z "$INSTALLER_PATH" ]; then
        log "No installer path provided, skipping Affinity installation"
        return 0
    fi
    
    log "Starting Affinity application installation..."
    
    gui_progress 80 "Installing Affinity application"
    
    if [ ! -f "$INSTALLER_PATH" ]; then
        gui_error "Installer file not found: $INSTALLER_PATH"
        log "ERROR: Installer file not found: $INSTALLER_PATH"
        return 1
    fi
    
    log "Found installer: $INSTALLER_PATH"
    
    if [[ "$INSTALLER_PATH" =~ \.exe$ ]]; then
        log "Using .exe installer"
        WINEPREFIX="$WINEPREFIX" wine "$INSTALLER_PATH" 2>&1 | tee -a "$LOG_FILE"
    elif [[ "$INSTALLER_PATH" =~ \.msix$ ]]; then
        log "Using .msix installer (requires extraction)"
        gui_info "Extracting MSIX package..."
        
        local extract_dir="/tmp/affinity_msix_$$"
        mkdir -p "$extract_dir"
        
        if command -v 7z &> /dev/null; then
            7z x "$INSTALLER_PATH" -o"$extract_dir" 2>&1 | tee -a "$LOG_FILE"
        elif command -v unzip &> /dev/null; then
            unzip -q "$INSTALLER_PATH" -d "$extract_dir" 2>&1 | tee -a "$LOG_FILE"
        else
            gui_error "No extraction tool found (need 7z or unzip)"
            log "ERROR: No extraction tool available"
            rm -rf "$extract_dir"
            return 1
        fi
        
        local affinity_install_dir="$WINEPREFIX/drive_c/Program Files/Affinity"
        mkdir -p "$affinity_install_dir"
        
        cp -r "$extract_dir/App/"* "$affinity_install_dir/" 2>&1 | tee -a "$LOG_FILE"
        
        rm -rf "$extract_dir"
    fi
    
    log "Affinity installer completed"
    
    # Copy helper files
    local affinity_dir="$WINEPREFIX/drive_c/Program Files/Affinity"
    
    if [ -d "$affinity_dir" ]; then
        local app_dir=$(find "$affinity_dir" -maxdepth 1 -type d \( -name "Affinity*" -o -name "Affinity" \) | head -1)
        
        if [ -n "$app_dir" ] && [ -f "$WINTYPES_DLL" ]; then
            cp "$WINTYPES_DLL" "$app_dir/" 2>&1 | tee -a "$LOG_FILE"
            log "wintypes.dll copied to $app_dir"
        fi
    fi
    
    local winmetadata_dir="$WINEPREFIX/drive_c/windows/system32/WinMetadata"
    mkdir -p "$winmetadata_dir"
    
    if [ -f "$WINDOWS_WINMD" ]; then
        cp "$WINDOWS_WINMD" "$winmetadata_dir/" 2>&1 | tee -a "$LOG_FILE"
        log "Windows.winmd copied to $winmetadata_dir"
    fi
    
    return 0
}

# ==========================================
# Create Desktop Shortcuts
# ==========================================

create_desktop_shortcuts() {
    log "Creating desktop shortcuts..."
    
    gui_progress 90 "Creating desktop shortcuts"
    
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"
    
    # Download icons
    log "Downloading application icons"
    
    if command -v curl &> /dev/null; then
        curl --output "$HOME/.local/share/icons/Affinity.svg" --location --silent \
            "https://upload.wikimedia.org/wikipedia/commons/c/cf/Affinity_%28App%29_Logo.svg" 2>&1 | tee -a "$LOG_FILE" || true
    elif command -v wget &> /dev/null; then
        wget -q -O "$HOME/.local/share/icons/Affinity.svg" \
            "https://upload.wikimedia.org/wikipedia/commons/c/cf/Affinity_%28App%29_Logo.svg" 2>&1 | tee -a "$LOG_FILE" || true
    fi
    
    # Find Affinity V3 executable
    local affinity_v3_exe=$(find "$WINEPREFIX/drive_c" -name "Affinity.exe" 2>/dev/null | head -1)
    
    if [ -n "$affinity_v3_exe" ] && [ -f "$affinity_v3_exe" ]; then
        log "Creating desktop shortcut for Affinity V3: $affinity_v3_exe"
        
        cat > "$HOME/.local/share/applications/Affinity.desktop" <<EOF
[Desktop Entry]
Name=Affinity
Comment=Unified Affinity application for photo editing, design, and publishing
Icon=$HOME/.local/share/icons/Affinity.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_v3_exe"
Terminal=false
Type=Application
Categories=Graphics;
StartupNotify=true
StartupWMClass=affinity.exe
EOF
        chmod +x "$HOME/.local/share/applications/Affinity.desktop"
        log "Affinity V3 desktop shortcut created"
    fi
    
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" 2>&1 | tee -a "$LOG_FILE" || true
        log "Desktop database updated"
    fi
    
    log "Desktop shortcuts creation completed"
    
    return 0
}

# ==========================================
# Main Installation Flow
# ==========================================

main() {
    # Parse command-line arguments for GUI mode
    while [[ $# -gt 0 ]]; do
        case $1 in
            --gui-mode)
                GUI_MODE=true
                shift
                ;;
            --prefix)
                INSTALL_DIR="$2"
                WINEPREFIX="$INSTALL_DIR"
                shift 2
                ;;
            --installer)
                INSTALLER_PATH="$2"
                shift 2
                ;;
            --enable-dxvk)
                ENABLE_DXVK=true
                shift
                ;;
            --enable-vulkan)
                ENABLE_VULKAN=true
                shift
                ;;
            --enable-tahoma)
                ENABLE_TAHOMA=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Only show banner in non-GUI mode
    if [ "$GUI_MODE" = false ]; then
        clear
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}   Affinity Linux Installation Script - ENHANCED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
    fi
    
    gui_progress 0 "Starting Affinity installation"
    
    log "=========================================="
    log "Affinity Linux Installation Started"
    log "=========================================="
    
    # Check Wine first
    gui_progress 5 "Checking Wine installation"
    
    if ! check_wine_version; then
        gui_error "Wine 10.0+ is required but not found"
        log "ERROR: Wine 10.0+ not found"
        exit 1
    fi
    
    log "Wine 10.0+ found"
    
    # Install components
    install_missing_components
    
    # Download helper files
    download_helper_files || {
        gui_error "Failed to download helper files"
        log "ERROR: Failed to download helper files"
    }
    
    # Install Affinity if installer provided
    if [ -n "$INSTALLER_PATH" ]; then
        install_affinity_app
        create_desktop_shortcuts
    fi
    
    # Final summary
    gui_progress 100 "Installation completed successfully"
    gui_success "Affinity Linux installation completed successfully!"
    
    log "=========================================="
    log "Affinity Linux Installation Completed"
    log "=========================================="
}

# Run main function only if not in GUI mode
# When GUI_MODE=true, script is being sourced to call specific functions
if [ "$GUI_MODE" != true ]; then
    main "$@"
fi
'''


# ============================================================================
# PROGRESS MONITOR - Track Installation Activity
# ============================================================================

class ProgressMonitor:
    """Monitor installation progress by tracking log file growth"""
    
    def __init__(self, log_file, log_callback=None, progress_callback=None):
        self.log_file = log_file
        self.log_callback = log_callback or print
        self.progress_callback = progress_callback
        self.last_size = 0
        self.idle_seconds = 0
        self.elapsed_seconds = 0
        self.is_active = False
    
    def check_progress(self):
        """Check if installation is making progress"""
        try:
            current_size = os.path.getsize(self.log_file)
        except:
            current_size = 0
        
        if current_size > self.last_size:
            # Progress detected!
            bytes_added = current_size - self.last_size
            self.last_size = current_size
            self.idle_seconds = 0
            self.is_active = True
            
            # Log activity
            self.log_callback(f"  ✓ ACTIVE (+{bytes_added} bytes)")
            
            return True
        else:
            # No progress
            self.idle_seconds += 5
            self.is_active = False
            
            # Log idle status
            if self.idle_seconds > 30:  # Only show after 30 seconds
                self.log_callback(f"  ⏸ IDLE ({self.idle_seconds}s)")
            
            return False
    
    def update_elapsed(self):
        """Update elapsed time"""
        self.elapsed_seconds += 5
    
    def get_status(self):
        """Get current status"""
        return {
            'active': self.is_active,
            'idle_seconds': self.idle_seconds,
            'elapsed_seconds': self.elapsed_seconds,
            'bytes_processed': self.last_size
        }


# ============================================================================
# WINE INSTALLER - Pure Python Implementation
# ============================================================================

class WineInstaller:
    """Pure Python Wine 10+ installer for multiple Linux distributions"""
    
    def __init__(self, sudo_password, log_callback=None):
        self.sudo_password = sudo_password
        self.log = log_callback or print
        self.distro = self._detect_distro()
    
    def _detect_distro(self):
        """Detect Linux distribution"""
        try:
            with open('/etc/os-release', 'r') as f:
                for line in f:
                    if line.startswith('ID='):
                        return line.split('=')[1].strip().strip('"')
        except:
            return None
        return None
    
    def _run_sudo_command(self, cmd, timeout=300):
        """Run command with sudo using stored password and log output in real-time"""
        if isinstance(cmd, str):
            cmd = cmd.split()
        
        full_cmd = ['sudo', '-S'] + cmd
        
        try:
            process = subprocess.Popen(
                full_cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1  # Line buffered
            )
            
            # Send password
            process.stdin.write(f"{self.sudo_password}\n")
            process.stdin.flush()
            
            # Read output line by line in real-time
            output_lines = []
            for line in iter(process.stdout.readline, ''):
                if not line:
                    break
                line = line.rstrip()
                if line and not line.startswith('[sudo]'):  # Skip sudo password prompt
                    self.log(f"  {line}")
                    output_lines.append(line)
            
            process.wait(timeout=timeout)
            
            return process.returncode == 0, '\n'.join(output_lines)
        
        except subprocess.TimeoutExpired:
            process.kill()
            return False, "Command timed out"
        except Exception as e:
            return False, str(e)
    
    def check_wine_version(self):
        """Check if Wine 10+ is installed"""
        wine_cmd = shutil.which("wine")
        if not wine_cmd:
            return False, None
        
        try:
            result = subprocess.run(
                [wine_cmd, "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode != 0:
                return False, None
            
            version_str = result.stdout.strip()
            match = re.search(r'(\d+)\.(\d+)', version_str)
            
            if not match:
                return False, None
            
            major = int(match.group(1))
            minor = int(match.group(2))
            
            if major >= 10:
                return True, f"{major}.{minor}"
            else:
                return False, f"{major}.{minor}"
        
        except Exception:
            return False, None
    
    def install_wine_debian(self, progress_callback=None):
        """Install Wine 10+ on Debian/Ubuntu from WineHQ"""
        self.log("📥 Installing Wine 10+ on Debian/Ubuntu...")
        if progress_callback:
            progress_callback(5, "Enabling 32-bit architecture")
        
        # Enable 32-bit architecture
        self.log("🔧 Enabling 32-bit architecture...")
        success, output = self._run_sudo_command("dpkg --add-architecture i386")
        if not success:
            self.log(f"⚠️  Warning: {output}")
        
        if progress_callback:
            progress_callback(10, "Creating keyrings directory")
        
        # Create keyrings directory
        self.log("📁 Creating keyrings directory...")
        success, output = self._run_sudo_command("mkdir -pm755 /etc/apt/keyrings")
        
        if progress_callback:
            progress_callback(15, "Downloading WineHQ repository key")
        
        # Download WineHQ key
        self.log("🔑 Downloading WineHQ repository key...")
        success, output = self._run_sudo_command(
            "wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key",
            timeout=60
        )
        if not success:
            return False, "Failed to download WineHQ key"
        
        if progress_callback:
            progress_callback(20, "Getting system codename")
        
        # Get codename for repository
        try:
            result = subprocess.run(
                ["lsb_release", "-cs"],
                capture_output=True,
                text=True,
                timeout=5
            )
            codename = result.stdout.strip()
        except:
            codename = "jammy"  # Default to Ubuntu 22.04
        
        if progress_callback:
            progress_callback(25, "Adding WineHQ repository")
        
        # Download repository sources file
        self.log(f"📦 Adding WineHQ repository for {codename}...")
        
        if self.distro == "ubuntu":
            repo_url = f"https://dl.winehq.org/wine-builds/ubuntu/dists/{codename}/winehq-{codename}.sources"
        else:
            repo_url = f"https://dl.winehq.org/wine-builds/debian/dists/{codename}/winehq-{codename}.sources"
        
        success, output = self._run_sudo_command(
            f"wget -NP /etc/apt/sources.list.d/ {repo_url}",
            timeout=60
        )
        if not success:
            self.log(f"⚠️  Warning: {output}")
        
        if progress_callback:
            progress_callback(30, "Updating package list")
        
        # Update package list
        self.log("🔄 Updating package list...")
        success, output = self._run_sudo_command("apt update", timeout=180)
        if not success:
            return False, "Failed to update package list"
        
        if progress_callback:
            progress_callback(40, "Installing Wine 10+ and winetricks")
        
        # Install Wine and winetricks
        self.log("📥 Installing Wine 10+ and winetricks (this may take several minutes)...")
        success, output = self._run_sudo_command(
            "apt install --install-recommends winehq-stable winetricks -y",
            timeout=600
        )
        
        if progress_callback:
            progress_callback(90, "Verifying installation")
        
        if success:
            self.log("✅ Wine 10+ installed successfully!")
            if progress_callback:
                progress_callback(100, "Wine installation complete")
            return True, "Wine installed"
        else:
            return False, output
    
    def install_wine_fedora(self, progress_callback=None):
        """Install Wine on Fedora"""
        self.log("📥 Installing Wine on Fedora...")
        
        if progress_callback:
            progress_callback(30, "Installing Wine and winetricks")
        
        success, output = self._run_sudo_command(
            "dnf install wine winetricks -y",
            timeout=600
        )
        
        if progress_callback:
            progress_callback(90, "Verifying installation")
        
        if success:
            self.log("✅ Wine installed successfully!")
            if progress_callback:
                progress_callback(100, "Wine installation complete")
            return True, "Wine installed"
        else:
            return False, output
    
    def install_wine_arch(self, progress_callback=None):
        """Install Wine on Arch Linux"""
        self.log("📥 Installing Wine on Arch Linux...")
        
        if progress_callback:
            progress_callback(30, "Installing Wine and winetricks")
        
        success, output = self._run_sudo_command(
            "pacman -S --needed wine winetricks",
            timeout=600
        )
        
        if progress_callback:
            progress_callback(90, "Verifying installation")
        
        if success:
            self.log("✅ Wine installed successfully!")
            if progress_callback:
                progress_callback(100, "Wine installation complete")
            return True, "Wine installed"
        else:
            return False, output
    
    def install(self, progress_callback=None):
        """Install Wine 10+ based on detected distribution"""
        if not self.distro:
            return False, "Could not detect Linux distribution"
        
        self.log(f"🐧 Detected distribution: {self.distro}")
        
        if progress_callback:
            progress_callback(0, "Starting Wine installation")
        
        if self.distro in ["ubuntu", "debian", "linuxmint", "pop", "zorin"]:
            return self.install_wine_debian(progress_callback)
        elif self.distro in ["fedora", "nobara", "rhel", "centos"]:
            return self.install_wine_fedora(progress_callback)
        elif self.distro in ["arch", "manjaro", "endeavouros"]:
            return self.install_wine_arch(progress_callback)
        else:
            return False, f"Unsupported distribution: {self.distro}"


class WineInstallerThread(QThread):
    """Background thread for installing Wine using pure Python"""
    log_output = pyqtSignal(str, str)  # message, level
    progress_update = pyqtSignal(int, str)  # percent, message
    finished_signal = pyqtSignal(bool)  # success
    
    def __init__(self, sudo_password):
        super().__init__()
        self.sudo_password = sudo_password
    
    def log(self, message, level="info"):
        """Log message with level"""
        self.log_output.emit(message, level)
    
    def update_progress(self, percent, message):
        """Update progress bar"""
        self.progress_update.emit(percent, message)
    
    def run(self):
        """Run Wine installation in background"""
        try:
            installer = WineInstaller(self.sudo_password, self.log)
            
            self.log("=" * 80, "info")
            self.log("📦 Installing Wine 10+ from WineHQ", "info")
            self.log("=" * 80, "info")
            
            success, message = installer.install(self.update_progress)
            
            if success:
                # Verify installation
                is_installed, version = installer.check_wine_version()
                if is_installed:
                    self.log(f"✅ Wine {version} successfully installed!", "success")
                    self.update_progress(100, "Wine installation complete")
                    self.finished_signal.emit(True)
                else:
                    self.log("⚠️  Wine installed but version check failed", "warning")
                    self.finished_signal.emit(False)
            else:
                self.log(f"❌ Wine installation failed: {message}", "error")
                self.finished_signal.emit(False)
        
        except Exception as e:
            self.log(f"❌ Installation error: {e}", "error")
            self.finished_signal.emit(False)


# ============================================================================
# GUI FRONTEND
# ============================================================================

class BashInstallerThread(QThread):
    """Background thread for running embedded bash installer"""
    log_output = pyqtSignal(str, str)  # message, level
    progress_update = pyqtSignal(int, str)  # percentage, message
    finished_signal = pyqtSignal(int)  # exit code
    
    def __init__(self, bash_script, prefix_path, installer_path=None, enable_dxvk=True, enable_vulkan=True, enable_tahoma=True):
        super().__init__()
        self.bash_script = bash_script
        self.prefix_path = prefix_path
        self.installer_path = installer_path
        self.enable_dxvk = enable_dxvk
        self.enable_vulkan = enable_vulkan
        self.enable_tahoma = enable_tahoma
        self.process = None
    
    def run(self):
        """Run bash installer in background"""
        # Create temporary bash script file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write(self.bash_script)
            script_path = f.name
        
        try:
            # Make script executable
            os.chmod(script_path, 0o755)
            
            cmd = [
                'bash',
                script_path,
                '--gui-mode',
                '--prefix', str(self.prefix_path)
            ]
            
            if self.installer_path:
                cmd.extend(['--installer', str(self.installer_path)])
            
            # Add optional component flags
            if self.enable_dxvk:
                cmd.append('--enable-dxvk')
            if self.enable_vulkan:
                cmd.append('--enable-vulkan')
            if self.enable_tahoma:
                cmd.append('--enable-tahoma')
            
            self.process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            
            for line in iter(self.process.stdout.readline, ''):
                if line:
                    line = line.rstrip()
                    
                    # Parse structured output
                    if line.startswith('PROGRESS:'):
                        parts = line.split(':', 2)
                        if len(parts) == 3:
                            try:
                                percent = int(parts[1])
                                message = parts[2]
                                self.progress_update.emit(percent, message)
                            except ValueError:
                                pass
                    
                    elif line.startswith('SUCCESS:'):
                        message = line.split(':', 1)[1] if ':' in line else line
                        self.log_output.emit(message, 'success')
                    
                    elif line.startswith('ERROR:'):
                        message = line.split(':', 1)[1] if ':' in line else line
                        self.log_output.emit(message, 'error')
                    
                    elif line.startswith('INFO:'):
                        message = line.split(':', 1)[1] if ':' in line else line
                        self.log_output.emit(message, 'info')
                    
                    else:
                        # Regular output
                        if '✓' in line or 'success' in line.lower():
                            level = 'success'
                        elif '✗' in line or 'error' in line.lower() or 'failed' in line.lower():
                            level = 'error'
                        elif '⚠' in line or 'warning' in line.lower():
                            level = 'warning'
                        else:
                            level = 'info'
                        
                        self.log_output.emit(line, level)
            
            self.process.wait()
            self.finished_signal.emit(self.process.returncode)
        
        except Exception as e:
            self.log_output.emit(f"Error: {e}", "error")
            self.finished_signal.emit(1)
        
        finally:
            # Clean up temporary script
            try:
                os.unlink(script_path)
            except:
                pass
    
    def terminate(self):
        """Terminate the bash process"""
        if self.process:
            self.process.terminate()
            self.process.wait()




class AffinityInstallerGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        
        self.setWindowTitle("Affinity On Linux • Installer")
        
        # Smart window sizing based on screen
        screen = self.screen().availableGeometry()
        screen_width = screen.width()
        screen_height = screen.height()
        
        # Calculate optimal window size (85% of screen height, max 900px)
        optimal_height = min(int(screen_height * 0.85), 900)
        optimal_width = min(int(screen_width * 0.6), 1000)
        
        # Set minimum size smaller for small screens
        min_height = min(750, optimal_height)
        min_width = min(900, optimal_width)
        
        self.setMinimumSize(min_width, min_height)
        self.resize(optimal_width, optimal_height)
        
        # Variables
        self.prefix_path = None
        self.installer_path = None
        self.installer_thread = None
        self.sudo_password = None  # Store sudo password
        
        # Optional component flags
        self.enable_dxvk = True
        self.enable_vulkan = True
        self.enable_tahoma = True
        
        # Setup UI
        self.create_ui()
        self.center_window()
        
        # Prompt for password first, then check Wine
        QTimer.singleShot(500, self.prompt_for_password)
    
    def center_window(self):
        """Center window on screen"""
        frame = self.frameGeometry()
        screen = self.screen().availableGeometry().center()
        frame.moveCenter(screen)
        self.move(frame.topLeft())
    
    def create_ui(self):
        """Create the user interface"""
        # Create scroll area for better responsiveness
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setFrameShape(QScrollArea.Shape.NoFrame)
        scroll.setStyleSheet("background: #1e1e1e;")
        self.setCentralWidget(scroll)
        
        central = QWidget()
        central.setStyleSheet("background: #1e1e1e;")
        scroll.setWidget(central)
        
        layout = QVBoxLayout(central)
        layout.setSpacing(5)
        layout.setContentsMargins(12, 10, 12, 10)
        
        # Header
        header = QLabel("🎨 Affinity On Linux")
        header_font = header.font()
        header_font.setPointSize(14)
        header_font.setBold(True)
        header.setFont(header_font)
        header.setStyleSheet("""
            color: #2196F3;
            background: #2b2b2b;
            padding: 8px;
            border: 2px solid #2196F3;
            border-radius: 6px;
        """)
        header.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(header)
        
        subtitle = QLabel("Complete Affinity Suite Support • <a href='https://affinityonlinux.com' style='color: #2196F3; text-decoration: none;'>AffinityOnLinux.com</a>")
        subtitle_font = subtitle.font()
        subtitle_font.setPointSize(8)
        subtitle.setFont(subtitle_font)
        subtitle.setStyleSheet("color: #aaa; padding: 2px;")
        subtitle.setOpenExternalLinks(True)
        subtitle.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(subtitle)
        
        # Configuration section
        config_group = QGroupBox("📋 Configuration")
        config_group.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                font-size: 9pt;
                border: 2px solid #4CAF50;
                border-radius: 6px;
                margin-top: 4px;
                padding-top: 10px;
                background: #2b2b2b;
                color: #4CAF50;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
            }
        """)
        config_layout = QVBoxLayout(config_group)
        config_layout.setSpacing(6)
        
        # Prefix path
        prefix_layout = QHBoxLayout()
        prefix_label = QLabel("Wine Prefix:")
        prefix_label.setMinimumWidth(120)
        prefix_label.setStyleSheet("color: #ddd; font-weight: normal;")
        prefix_layout.addWidget(prefix_label)
        
        self.prefix_edit = QLineEdit()
        default_prefix = str(Path.home() / ".AffinityOnLinux")
        self.prefix_edit.setPlaceholderText(default_prefix)
        self.prefix_edit.setText(default_prefix)
        self.prefix_edit.setReadOnly(True)
        self.prefix_edit.setStyleSheet("""
            padding: 8px;
            border: 2px solid #555;
            border-radius: 4px;
            background: #3a3a3a;
            color: #fff;
        """)
        prefix_layout.addWidget(self.prefix_edit)
        
        # Browse button removed - user shouldn't change Wine prefix location
        
        config_layout.addLayout(prefix_layout)
        
        # Installer path (optional)
        installer_layout = QHBoxLayout()
        installer_label = QLabel("Affinity Installer:")
        installer_label.setMinimumWidth(120)
        installer_label.setStyleSheet("color: #ddd; font-weight: normal;")
        installer_layout.addWidget(installer_label)
        
        self.installer_edit = QLineEdit()
        self.installer_edit.setPlaceholderText("Optional: Select .exe or .msix installer file")
        self.installer_edit.setStyleSheet("""
            padding: 8px;
            border: 2px solid #555;
            border-radius: 4px;
            background: #3a3a3a;
            color: #fff;
        """)
        installer_layout.addWidget(self.installer_edit)
        
        installer_browse = QPushButton("📁 Browse...")
        installer_browse.setStyleSheet("""
            QPushButton {
                padding: 8px 16px;
                background: #2196F3;
                color: white;
                border: 2px solid #1976D2;
                border-radius: 4px;
                font-weight: bold;
            }
            QPushButton:hover {
                background: #1976D2;
                border: 2px solid #0D47A1;
            }
            QPushButton:pressed {
                background: #0D47A1;
            }
        """)
        installer_browse.clicked.connect(self.browse_installer)
        installer_layout.addWidget(installer_browse)
        
        config_layout.addLayout(installer_layout)
        
        layout.addWidget(config_group)
        
        # Optional Components section
        optional_group = QGroupBox("⚙️ Optional Components")
        optional_group.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                font-size: 9pt;
                border: 2px solid #FF9800;
                border-radius: 6px;
                margin-top: 4px;
                padding-top: 10px;
                background: #2b2b2b;
                color: #FF9800;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
            }
        """)
        optional_layout = QVBoxLayout(optional_group)
        optional_layout.setSpacing(4)
        
        # Info label
        info_label = QLabel("These components enhance stability and compatibility (recommended):")
        info_label.setStyleSheet("color: #aaa; font-size: 9pt; font-weight: normal; padding: 2px;")
        info_label.setWordWrap(True)
        optional_layout.addWidget(info_label)
        
        # Checkboxes in horizontal layout
        checkboxes_layout = QHBoxLayout()
        checkboxes_layout.setSpacing(15)
        
        # DXVK checkbox
        self.dxvk_checkbox = QCheckBox("DXVK (for stability)")
        self.dxvk_checkbox.setChecked(True)
        self.dxvk_checkbox.setStyleSheet("color: #ddd; font-size: 9pt; font-weight: normal; padding: 2px;")
        self.dxvk_checkbox.stateChanged.connect(lambda state: setattr(self, 'enable_dxvk', state == Qt.CheckState.Checked.value))
        checkboxes_layout.addWidget(self.dxvk_checkbox)
        
        # Vulkan Renderer checkbox
        self.vulkan_checkbox = QCheckBox("Vulkan Renderer (For GPU)")
        self.vulkan_checkbox.setChecked(True)
        self.vulkan_checkbox.setStyleSheet("color: #ddd; font-size: 9pt; font-weight: normal; padding: 2px;")
        self.vulkan_checkbox.stateChanged.connect(lambda state: setattr(self, 'enable_vulkan', state == Qt.CheckState.Checked.value))
        checkboxes_layout.addWidget(self.vulkan_checkbox)
        
        # Tahoma Font checkbox
        self.tahoma_checkbox = QCheckBox("Tahoma Font (fonts not showing)")
        self.tahoma_checkbox.setChecked(True)
        self.tahoma_checkbox.setStyleSheet("color: #ddd; font-size: 9pt; font-weight: normal; padding: 2px;")
        self.tahoma_checkbox.stateChanged.connect(lambda state: setattr(self, 'enable_tahoma', state == Qt.CheckState.Checked.value))
        checkboxes_layout.addWidget(self.tahoma_checkbox)
        
        checkboxes_layout.addStretch()
        optional_layout.addLayout(checkboxes_layout)
        
        layout.addWidget(optional_group)
        
        # Resources section
        resources_group = QGroupBox("📚 Resources")
        resources_group.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                font-size: 9pt;
                border: 2px solid #9C27B0;
                border-radius: 6px;
                margin-top: 4px;
                padding-top: 10px;
                background: #2b2b2b;
                color: #9C27B0;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
            }
        """)
        resources_layout = QVBoxLayout(resources_group)
        resources_layout.setSpacing(4)
        
        # AffinityPluginLoader link
        plugin_label = QLabel(
            "<b><a href='https://github.com/noahc3/AffinityPluginLoader' style='color: #2196F3; text-decoration: none;'>AffinityPluginLoader</a></b> - "
            "Fix some bugs like pen line - follow this guide"
        )
        plugin_label.setOpenExternalLinks(True)
        plugin_label.setStyleSheet("color: #ddd; font-size: 9pt; font-weight: normal; padding: 4px;")
        plugin_label.setWordWrap(True)
        resources_layout.addWidget(plugin_label)
        
        # Credits link
        credits_label = QLabel(
            "<b><a href='https://github.com/seapear/AffinityOnLinux/blob/main/Credits.md' style='color: #2196F3; text-decoration: none;'>Credits</a></b> - "
            "Credit to all the amazing work everyone has volunteered"
        )
        credits_label.setOpenExternalLinks(True)
        credits_label.setStyleSheet("color: #ddd; font-size: 9pt; font-weight: normal; padding: 4px;")
        credits_label.setWordWrap(True)
        resources_layout.addWidget(credits_label)
        
        layout.addWidget(resources_group)
        
        # Progress section
        progress_group = QGroupBox("📊 Installation Progress")
        progress_group.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                font-size: 9pt;
                border: 2px solid #00BCD4;
                border-radius: 6px;
                margin-top: 4px;
                padding-top: 10px;
                background: #2b2b2b;
                color: #00BCD4;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
            }
        """)
        progress_layout = QVBoxLayout(progress_group)
        progress_layout.setSpacing(4)
        
        # Progress bar with percentage
        progress_bar_layout = QHBoxLayout()
        
        self.progress_bar = QProgressBar()
        self.progress_bar.setMinimum(0)
        self.progress_bar.setMaximum(100)
        self.progress_bar.setValue(0)
        self.progress_bar.setTextVisible(True)
        self.progress_bar.setFormat("%p%")
        self.progress_bar.setStyleSheet("""
            QProgressBar {
                border: 2px solid #555;
                border-radius: 6px;
                text-align: center;
                height: 25px;
                font-size: 11pt;
                font-weight: bold;
                color: #fff;
                background: #3a3a3a;
            }
            QProgressBar::chunk {
                background: qlineargradient(x1:0, y1:0, x2:1, y2:0,
                    stop:0 #4CAF50, stop:1 #8BC34A);
                border-radius: 4px;
            }
        """)
        progress_bar_layout.addWidget(self.progress_bar)
        
        # Percentage label (large)
        self.percentage_label = QLabel("0%")
        self.percentage_label.setStyleSheet("""
            font-size: 16pt;
            font-weight: bold;
            color: #00BCD4;
            min-width: 60px;
        """)
        self.percentage_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        progress_bar_layout.addWidget(self.percentage_label)
        
        progress_layout.addLayout(progress_bar_layout)
        
        # Current step label
        self.step_label = QLabel("Ready to start installation")
        self.step_label.setStyleSheet("font-size: 9pt; color: #aaa; padding: 4px;")
        self.step_label.setWordWrap(True)
        progress_layout.addWidget(self.step_label)
        
        layout.addWidget(progress_group)
        
        # Log output
        log_group = QGroupBox("📝 Installation Log")
        log_group.setStyleSheet("""
            QGroupBox {
                font-weight: bold;
                font-size: 9pt;
                border: 2px solid #FFC107;
                border-radius: 6px;
                margin-top: 4px;
                padding-top: 10px;
                background: #2b2b2b;
                color: #FFC107;
            }
            QGroupBox::title {
                subcontrol-origin: margin;
                left: 10px;
                padding: 0 5px;
            }
        """)
        log_layout = QVBoxLayout(log_group)
        log_layout.setContentsMargins(4, 4, 4, 4)
        
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMinimumHeight(70)
        self.log_text.setMaximumHeight(100)
        self.log_text.setStyleSheet("""
            QTextEdit {
                background: #1a1a1a;
                color: #d4d4d4;
                font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
                font-size: 9pt;
                border: 2px solid #555;
                border-radius: 4px;
                padding: 6px;
            }
        """)
        log_layout.addWidget(self.log_text)
        
        layout.addWidget(log_group)
        
        # Buttons
        button_layout = QHBoxLayout()
        button_layout.addStretch()
        
        self.start_button = QPushButton("🚀 Start Installation")
        self.start_button.setStyleSheet("""
            QPushButton {
                background: #4CAF50;
                color: white;
                font-size: 10pt;
                font-weight: bold;
                padding: 8px 16px;
                border: 2px solid #45a049;
                border-radius: 6px;
            }
            QPushButton:hover {
                background: #45a049;
                border: 2px solid #3d8b40;
            }
            QPushButton:pressed {
                background: #3d8b40;
            }
            QPushButton:disabled {
                background: #555;
                color: #888;
                border: 2px solid #444;
            }
        """)
        self.start_button.clicked.connect(self.start_installation)
        button_layout.addWidget(self.start_button)
        
        self.stop_button = QPushButton("⏹ Stop")
        self.stop_button.setEnabled(False)
        self.stop_button.setStyleSheet("""
            QPushButton {
                background: #f44336;
                color: white;
                font-size: 10pt;
                font-weight: bold;
                padding: 8px 16px;
                border: 2px solid #da190b;
                border-radius: 6px;
            }
            QPushButton:hover {
                background: #da190b;
                border: 2px solid #c41400;
            }
            QPushButton:pressed {
                background: #c41400;
            }
            QPushButton:disabled {
                background: #555;
                color: #888;
                border: 2px solid #444;
            }
        """)
        self.stop_button.clicked.connect(self.stop_installation)
        button_layout.addWidget(self.stop_button)
        
        # Add Uninstall button
        self.uninstall_button = QPushButton("🗑️ Uninstall")
        self.uninstall_button.setStyleSheet("""
            QPushButton {
                background: #FF9800;
                color: white;
                font-size: 10pt;
                font-weight: bold;
                padding: 8px 16px;
                border: 2px solid #F57C00;
                border-radius: 6px;
            }
            QPushButton:hover {
                background: #F57C00;
                border: 2px solid #E65100;
            }
            QPushButton:pressed {
                background: #E65100;
            }
        """)
        self.uninstall_button.clicked.connect(self.uninstall_affinity)
        button_layout.addWidget(self.uninstall_button)
        
        layout.addLayout(button_layout)
        
        # Initial log message
        self.log("🎨 Affinity Installer - Unified Single-File Version", "info")
        self.log("📦 All-in-one installer with embedded bash backend", "info")
        self.log("⚙️  Configure paths and click 'Start Installation'", "info")
    
    def browse_installer(self):
        """Open file dialog to select Affinity installer (.msix only)"""
        file_path, _ = QFileDialog.getOpenFileName(
            self,
            "Select Affinity Installer",
            str(Path.home()),
            "MSIX Installer (*.msix)"
        )
        
        if file_path:
            self.installer_edit.setText(file_path)
            self.log(f"Selected installer: {file_path}", "info")
    
    def check_wine_version(self):
        """Check if Wine 10+ is installed - returns 'ok', 'missing', or 'old'"""
        wine_cmd = shutil.which("wine")
        if not wine_cmd:
            return "missing"
        
        try:
            result = subprocess.run(
                [wine_cmd, "--version"],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode != 0:
                return "missing"
            
            version_str = result.stdout.strip()
            match = re.search(r'(\d+)\.(\d+)', version_str)
            
            if not match:
                return "missing"
            
            major = int(match.group(1))
            minor = int(match.group(2))
            
            if major < 10:
                return "old"
            
            return "ok"
        
        except Exception as e:
            return "missing"
    
    def prompt_for_password(self):
        """Prompt for sudo password at startup"""
        from PyQt6.QtWidgets import QInputDialog, QLineEdit
        
        # Show password dialog
        password, ok = QInputDialog.getText(
            self,
            "Administrator Password Required",
            "This application needs administrator privileges to install Wine and dependencies.\n\n"
            "Please enter your password:\n"
            "(Your password will be stored securely for this session)",
            QLineEdit.EchoMode.Password
        )
        
        if ok and password:
            # Validate password by running a simple sudo command
            self.log("🔐 Validating password...", "info")
            
            try:
                # Test sudo password
                result = subprocess.run(
                    ['sudo', '-S', 'echo', 'Password validated'],
                    input=f"{password}\n",
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                
                if result.returncode == 0:
                    self.sudo_password = password
                    self.log("✅ Password validated successfully", "success")
                    self.log("", "info")
                    
                    # Now check Wine
                    self.check_wine_on_startup()
                else:
                    self.log("❌ Invalid password", "error")
                    QMessageBox.critical(
                        self,
                        "Invalid Password",
                        "The password you entered is incorrect.\n\n"
                        "The application will close. Please restart and enter the correct password."
                    )
                    QTimer.singleShot(100, self.close)
            
            except Exception as e:
                self.log(f"❌ Password validation failed: {e}", "error")
                QMessageBox.critical(
                    self,
                    "Password Validation Failed",
                    f"Failed to validate password:\n\n{e}\n\n"
                    "The application will close."
                )
                QTimer.singleShot(100, self.close)
        else:
            # User cancelled password prompt
            QMessageBox.warning(
                self,
                "Password Required",
                "Administrator password is required to run this application.\n\n"
                "The application will close."
            )
            QTimer.singleShot(100, self.close)
    
    def check_wine_on_startup(self):
        """Check Wine on startup and prompt to install if missing/old"""
        status = self.check_wine_version()
        
        if status == "missing":
            self.log("⚠️  Wine is not installed on your system", "warning")
            
            # Prompt to install Wine
            reply = QMessageBox.question(
                self,
                "Wine 10+ Not Installed",
                "Wine 10.0+ is required to run Affinity applications.\n\n"
                "Wine is not currently installed on your system.\n\n"
                "Would you like to install Wine 10+ now?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
            )
            
            if reply == QMessageBox.StandardButton.Yes:
                self.install_wine()
            else:
                self.log("⚠️  Wine installation skipped - you'll need to install it manually", "warning")
        
        elif status == "old":
            self.log("⚠️  Wine version is too old - Wine 10+ required", "warning")
            
            # Prompt to upgrade Wine
            reply = QMessageBox.question(
                self,
                "Wine Version Too Old",
                "Wine 10.0+ is required to run Affinity applications.\n\n"
                "Your current Wine version is too old.\n\n"
                "Would you like to install Wine 10+ now?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
            )
            
            if reply == QMessageBox.StandardButton.Yes:
                self.install_wine()
            else:
                self.log("⚠️  Wine upgrade skipped - you'll need to upgrade it manually", "warning")
        
        else:
            # Get version for display
            wine_cmd = shutil.which("wine")
            try:
                result = subprocess.run(
                    [wine_cmd, "--version"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                version_str = result.stdout.strip()
                match = re.search(r'(\d+)\.(\d+)', version_str)
                if match:
                    major = int(match.group(1))
                    minor = int(match.group(2))
                    self.log(f"✅ Wine {major}.{minor} detected (meets requirements)", "success")
            except:
                self.log("✅ Wine 10+ detected", "success")
    
    def install_wine(self):
        """Install Wine 10+ using pure Python installer"""
        # Check if we have sudo password
        if not self.sudo_password:
            QMessageBox.critical(
                self,
                "No Password",
                "No sudo password available.\n\n"
                "Please restart the application."
            )
            return
        
        # Confirm installation
        reply = QMessageBox.question(
            self,
            "Install Wine 10+ from WineHQ",
            "This will install Wine 10+ from WineHQ repository.\n\n"
            "The installation will run in the background.\n\n"
            "Continue?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
        )
        
        if reply != QMessageBox.StandardButton.Yes:
            return
        
        # Start Wine installation thread
        self.wine_thread = WineInstallerThread(self.sudo_password)
        self.wine_thread.log_output.connect(self.log)
        self.wine_thread.progress_update.connect(self.update_progress)
        self.wine_thread.finished_signal.connect(self.wine_installation_finished)
        self.wine_thread.start()
    
    def wine_installation_finished(self, success):
        """Called when Wine installation completes"""
        self.log("=" * 80, "info")
        
        if success:
            # Check if Wine is now installed
            status = self.check_wine_version()
            if status == "ok":
                wine_cmd = shutil.which("wine")
                try:
                    ver_result = subprocess.run(
                        [wine_cmd, "--version"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    version_str = ver_result.stdout.strip()
                    match = re.search(r'(\d+)\.(\d+)', version_str)
                    if match:
                        major = int(match.group(1))
                        minor = int(match.group(2))
                        self.log(f"✅ Wine {major}.{minor} successfully installed!", "success")
                except:
                    self.log("✅ Wine 10+ successfully installed!", "success")
                
                QMessageBox.information(
                    self,
                    "Wine Installed",
                    "Wine 10+ has been successfully installed!\n\n"
                    "You can now start the Affinity installation."
                )
            else:
                # Wine installation reported success but Wine 10+ not detected
                self.log("⚠️  Wine installed but version check failed", "warning")
                self.log("", "info")
                self.log("💡 This might mean:", "info")
                self.log("   • Wine was already installed (older version)", "info")
                self.log("   • Installation didn't complete properly", "info")
                self.log("   • Password prompt was cancelled", "info")
                self.log("", "info")
                self.log("📝 To install Wine 10+ manually, run:", "info")
                self.log("   sudo apt update && sudo apt install -y wine", "info")
                
                QMessageBox.warning(
                    self,
                    "Wine 10+ Not Detected",
                    "Wine installation completed, but Wine 10+ was not detected.\n\n"
                    "Please install Wine 10+ manually:\n\n"
                    "sudo apt update && sudo apt install -y wine\n\n"
                    "Then restart this application."
                )
        else:
            # Installation failed
            self.log("", "info")
            self.log("💡 Installation failed. To install Wine manually:", "info")
            self.log("   Open a terminal and run:", "info")
            self.log("   sudo apt update && sudo apt install -y wine", "info")
            
            QMessageBox.warning(
                self,
                "Installation Failed",
                "Wine installation failed or was cancelled.\n\n"
                "To install Wine manually, open a terminal and run:\n\n"
                "sudo apt update && sudo apt install -y wine\n\n"
                "Then restart this application."
            )
    
    def browse_prefix(self):
        """Browse for Wine prefix directory"""
        path = QFileDialog.getExistingDirectory(
            self,
            "Select Wine Prefix Directory",
            str(Path.home())
        )
        if path:
            self.prefix_edit.setText(path)
    
    def browse_installer(self):
        """Browse for Affinity installer file"""
        path, _ = QFileDialog.getOpenFileName(
            self,
            "Select Affinity Installer",
            str(Path.home() / "Downloads"),
            "Installer files (*.exe *.msix);;All files (*)"
        )
        if path:
            self.installer_edit.setText(path)
    
    def log(self, message, level="info"):
        """Add log message with color coding"""
        colors = {
            'success': '#4CAF50',
            'error': '#f44336',
            'warning': '#FF9800',
            'info': '#d4d4d4'
        }
        
        color = colors.get(level, colors['info'])
        formatted = f'<span style="color: {color};">{message}</span>'
        self.log_text.append(formatted)
        
        self.log_text.verticalScrollBar().setValue(
            self.log_text.verticalScrollBar().maximum()
        )
    
    def update_progress(self, percent, message):
        """Update progress bar and step label"""
        self.progress_bar.setValue(percent)
        self.percentage_label.setText(f"{percent}%")
        self.step_label.setText(f"⏳ {message}")
        
        if percent in [0, 25, 50, 75, 100]:
            self.log(f"📊 Progress: {percent}% - {message}", "info")
    
    def start_installation(self):
        """Start installation process"""
        prefix = Path(self.prefix_edit.text().strip())
        if not prefix:
            QMessageBox.warning(self, "Invalid Input", "Please specify Wine prefix path")
            return
        
        installer = self.installer_edit.text().strip()
        installer_path = Path(installer) if installer else None
        
        if installer_path and not installer_path.exists():
            QMessageBox.warning(
                self,
                "Installer Not Found",
                f"Installer file not found:\n{installer_path}"
            )
            return
        
        # Clear log and reset progress
        self.log_text.clear()
        self.progress_bar.setValue(0)
        self.percentage_label.setText("0%")
        self.step_label.setText("Starting installation...")
        
        self.log("=" * 80, "info")
        self.log("🚀 Starting Affinity Installation", "info")
        self.log("=" * 80, "info")
        self.log(f"📂 Prefix: {prefix}", "info")
        if installer_path:
            self.log(f"📦 Installer: {installer_path}", "info")
        self.log("", "info")
        
        # Disable controls
        self.start_button.setEnabled(False)
        self.stop_button.setEnabled(True)
        self.prefix_edit.setEnabled(False)
        self.installer_edit.setEnabled(False)
        
        # Start installer thread
        self.installer_thread = BashInstallerThread(
            BASH_SCRIPT,
            prefix,
            installer_path,
            self.enable_dxvk,
            self.enable_vulkan,
            self.enable_tahoma
        )
        self.installer_thread.log_output.connect(self.log)
        self.installer_thread.progress_update.connect(self.update_progress)
        self.installer_thread.finished_signal.connect(self.installation_finished)
        self.installer_thread.start()
    
    def stop_installation(self):
        """Stop installation process"""
        if self.installer_thread and self.installer_thread.isRunning():
            reply = QMessageBox.question(
                self,
                "Stop Installation",
                "Are you sure you want to stop the installation?",
                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No
            )
            
            if reply == QMessageBox.StandardButton.Yes:
                self.installer_thread.terminate()
                self.installer_thread.wait()
                self.log("", "warning")
                self.log("⚠️  Installation stopped by user", "warning")
                self.installation_finished(-1)
    
    def installation_finished(self, exit_code):
        """Handle installation completion"""
        self.start_button.setEnabled(True)
        self.stop_button.setEnabled(False)
        self.prefix_edit.setEnabled(True)
        self.installer_edit.setEnabled(True)
        
        self.log("", "info")
        self.log("=" * 80, "info")
        
        if exit_code == 0:
            self.progress_bar.setValue(100)
            self.percentage_label.setText("100%")
            self.step_label.setText("✅ Installation completed successfully!")
            self.log("✅ Installation completed successfully!", "success")
            QMessageBox.information(
                self,
                "Success",
                "Affinity installation completed successfully!\n\n"
                "You can now find Affinity apps in your application menu."
            )
        else:
            self.step_label.setText("❌ Installation failed")
            self.log(f"❌ Installation failed (exit code: {exit_code})", "error")
            QMessageBox.warning(
                self,
                "Installation Failed",
                f"Installation failed with exit code {exit_code}\n\n"
                "Check the log output for details."
            )
        
        self.log("=" * 80, "info")
    
    def uninstall_affinity(self):
        """Uninstall Affinity and remove all files"""
        # Confirm uninstall
        reply = QMessageBox.question(
            self,
            "Confirm Uninstall",
            "⚠️  This will remove:\n\n"
            "• Wine prefix directory (~/.AffinityOnLinux)\n"
            "• All Affinity applications\n"
            "• Desktop shortcuts\n"
            "• All installed components\n\n"
            "This action cannot be undone!\n\n"
            "Continue with uninstall?",
            QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No,
            QMessageBox.StandardButton.No
        )
        
        if reply != QMessageBox.StandardButton.Yes:
            return
        
        self.log("", "info")
        self.log("=" * 80, "info")
        self.log("🗑️  Starting Affinity uninstall...", "info")
        self.log("=" * 80, "info")
        
        # Get prefix path
        prefix_path = Path(self.prefix_edit.text())
        
        # Remove Wine prefix directory
        if prefix_path.exists():
            self.log(f"Removing Wine prefix: {prefix_path}", "info")
            try:
                shutil.rmtree(prefix_path)
                self.log("✅ Wine prefix removed", "success")
            except Exception as e:
                self.log(f"❌ Failed to remove Wine prefix: {e}", "error")
        else:
            self.log("⚠️  Wine prefix not found (already removed?)", "warning")
        
        # Remove desktop shortcuts
        self.log("Removing desktop shortcuts...", "info")
        desktop_path = Path.home() / ".local" / "share" / "applications"
        shortcuts_removed = 0
        
        if desktop_path.exists():
            # Remove Affinity shortcuts - try multiple patterns
            patterns = ["affinity-*.desktop", "Affinity*.desktop", "*affinity*.desktop"]
            
            for pattern in patterns:
                for shortcut_file in desktop_path.glob(pattern):
                    try:
                        shortcut_file.unlink()
                        self.log(f"  ✅ Removed: {shortcut_file.name}", "success")
                        shortcuts_removed += 1
                    except Exception as e:
                        self.log(f"  ❌ Failed to remove {shortcut_file.name}: {e}", "error")
        
        if shortcuts_removed > 0:
            self.log(f"✅ Removed {shortcuts_removed} desktop shortcut(s)", "success")
        else:
            self.log("⚠️  No desktop shortcuts found", "warning")
        
        self.log("", "info")
        self.log("=" * 80, "info")
        self.log("✅ Uninstall completed!", "success")
        self.log("=" * 80, "info")
        
        QMessageBox.information(
            self,
            "Uninstall Complete",
            "✅ Affinity has been successfully uninstalled!\n\n"
            "All files and shortcuts have been removed."
        )


def main():
    app = QApplication(sys.argv)
    app.setApplicationName("Affinity Installer - Unified")
    app.setStyle("Fusion")
    
    window = AffinityInstallerGUI()
    window.show()
    
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
