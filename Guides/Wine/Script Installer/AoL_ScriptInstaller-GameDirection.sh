#!/bin/bash

################################################################################
# Affinity on Linux Installation Script - Beta v0.3
# Created by GameDirection
# 
#
# Features:
# - Interactive arrow-key menu
# - Auto Wine 10+ installation
# - Unified logging
# - Final verification
# - Smart continue/resume
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

# Installation directory
INSTALL_DIR="$HOME/.AffinityLinux"
WINEPREFIX="$INSTALL_DIR"

# Unified log file
LOG_FILE="$HOME/affinity_install_$(date +%Y%m%d_%H%M%S).log"

# Overall progress tracking
TOTAL_STEPS=10
CURRENT_STEP=0

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

# ==========================================
# Logging Functions
# ==========================================

log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
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
# Interactive Menu Functions
# ==========================================

show_menu() {
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
        
        # Read input - handle both arrow keys and numbers
        IFS= read -rsn1 key
        
        # Check if it's a number
        if [[ $key =~ ^[0-9]$ ]]; then
            local num=$((key - 1))
            if [ $num -ge 0 ] && [ $num -lt ${#options[@]} ]; then
                return $num
            fi
        # Check for escape sequence (arrow keys)
        elif [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case $key in
                '[A') # Up arrow
                    ((selected--))
                    if [ $selected -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                    ;;
                '[B') # Down arrow
                    ((selected++))
                    if [ $selected -ge ${#options[@]} ]; then
                        selected=0
                    fi
                    ;;
            esac
        # Check for Enter key
        elif [[ $key == "" ]]; then
            return $selected
        fi
    done
}

# ==========================================
# Wine Installation
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
    local minor=$(echo "$wine_version" | cut -d. -f2)
    
    log "Found Wine version: $wine_version"
    
    # Need Wine 10.0 or higher
    if [ "$major" -ge 10 ]; then
        WINE_VERSION_OK=true
        return 0
    fi
    
    log "Wine version too old (need 10.0+)"
    return 1
}

install_wine() {
    log "Installing Wine 10.0+..."
    
    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local distro=$ID
    else
        log "Cannot detect distribution"
        return 1
    fi
    
    case $distro in
        ubuntu|debian|linuxmint|pop|zorin)
            log "Installing Wine on Debian-based system..."
            
            # Enable 32-bit architecture
            sudo dpkg --add-architecture i386
            
            # Add WineHQ repository
            sudo mkdir -pm755 /etc/apt/keyrings
            sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
            
            # Add repository based on distribution
            if [ "$distro" = "ubuntu" ]; then
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
            else
                sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
            fi
            
            # Update and install (including winetricks)
            sudo apt update
            sudo apt install --install-recommends winehq-stable winetricks -y
            ;;
            
        arch|manjaro|endeavouros)
            log "Installing Wine on Arch-based system..."
            sudo pacman -S --needed wine winetricks
            ;;
            
        fedora)
            log "Installing Wine on Fedora..."
            sudo dnf install wine winetricks -y
            ;;
            
        *)
            log "Unsupported distribution: $distro"
            echo -e "${RED}Please install Wine 10.0+ manually${NC}"
            return 1
            ;;
    esac
    
    # Verify installation
    if check_wine_version; then
        log "Wine installed successfully"
        return 0
    else
        log "Wine installation failed"
        return 1
    fi
}

# ==========================================
# Winetricks Installation
# ==========================================

check_winetricks() {
    if command -v winetricks &> /dev/null; then
        log "Winetricks found: $(command -v winetricks)"
        return 0
    fi
    
    # Check for local installation
    if [ -f "$HOME/winetricks" ] && [ -x "$HOME/winetricks" ]; then
        log "Winetricks found locally: $HOME/winetricks"
        return 0
    fi
    
    log "Winetricks not found"
    return 1
}

install_winetricks_manual() {
    log "Installing winetricks manually..."
    echo -e "${YELLOW}📥 Downloading winetricks...${NC}"
    
    local winetricks_path="$HOME/winetricks"
    
    if curl --output "$winetricks_path" --location \
        "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" 2>&1 | tee -a "$LOG_FILE"; then
        chmod +x "$winetricks_path"
        echo -e "${GREEN}✓ Winetricks downloaded to $winetricks_path${NC}"
        log "Winetricks downloaded successfully"
        
        # Ask if user wants to install globally
        echo ""
        echo -e "${YELLOW}Install winetricks globally to /usr/local/bin?${NC}"
        echo "This allows you to use 'winetricks' command from anywhere."
        read -p "Install globally? (y/n): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if sudo mv "$winetricks_path" /usr/local/bin/winetricks 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✓ Winetricks installed globally${NC}"
                log "Winetricks installed to /usr/local/bin"
            else
                echo -e "${YELLOW}⚠ Failed to install globally, using local copy${NC}"
                log "WARNING: Failed to install winetricks globally"
                # Restore local copy if move failed
                curl --output "$winetricks_path" --location \
                    "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" 2>&1 | tee -a "$LOG_FILE"
                chmod +x "$winetricks_path"
            fi
        else
            echo -e "${CYAN}ℹ Using local winetricks at $winetricks_path${NC}"
            log "Using local winetricks installation"
        fi
        
        return 0
    else
        echo -e "${RED}✗ Failed to download winetricks${NC}"
        log "ERROR: Failed to download winetricks"
        return 1
    fi
}

install_winetricks() {
    log "Installing winetricks..."
    
    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local distro=$ID
    else
        log "Cannot detect distribution"
        install_winetricks_manual
        return $?
    fi
    
    echo -e "${CYAN}📦 Installing winetricks for $distro...${NC}"
    
    case $distro in
        ubuntu|debian|linuxmint|pop|zorin)
            log "Installing winetricks on Debian-based system..."
            sudo apt update
            if sudo apt install winetricks -y 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✓ Winetricks installed via apt${NC}"
                log "Winetricks installed successfully"
                return 0
            else
                echo -e "${YELLOW}⚠ Failed to install via apt, trying manual installation...${NC}"
                log "WARNING: apt installation failed, falling back to manual"
                install_winetricks_manual
                return $?
            fi
            ;;
            
        arch|manjaro|endeavouros)
            log "Installing winetricks on Arch-based system..."
            if sudo pacman -S --needed winetricks 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✓ Winetricks installed via pacman${NC}"
                log "Winetricks installed successfully"
                return 0
            else
                echo -e "${YELLOW}⚠ Failed to install via pacman, trying manual installation...${NC}"
                log "WARNING: pacman installation failed, falling back to manual"
                install_winetricks_manual
                return $?
            fi
            ;;
            
        fedora)
            log "Installing winetricks on Fedora..."
            if sudo dnf install winetricks -y 2>&1 | tee -a "$LOG_FILE"; then
                echo -e "${GREEN}✓ Winetricks installed via dnf${NC}"
                log "Winetricks installed successfully"
                return 0
            else
                echo -e "${YELLOW}⚠ Failed to install via dnf, trying manual installation...${NC}"
                log "WARNING: dnf installation failed, falling back to manual"
                install_winetricks_manual
                return $?
            fi
            ;;
            
        *)
            log "Unsupported distribution: $distro, using manual installation"
            echo -e "${YELLOW}⚠ Unsupported distribution, using manual installation${NC}"
            install_winetricks_manual
            return $?
            ;;
    esac
}

# ==========================================
# Visual Progress Functions
# ==========================================

show_progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %3d%% " $percentage
}

next_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local percentage=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📊 Overall Progress: Step $CURRENT_STEP/$TOTAL_STEPS ($percentage%)${NC}"
    show_progress_bar $CURRENT_STEP $TOTAL_STEPS
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "Progress: Step $CURRENT_STEP/$TOTAL_STEPS ($percentage%)"
}

# ==========================================
# Wine Process Management
# ==========================================

kill_all_wine_processes() {
    log "Cleaning up wine processes..."
    echo -e "${YELLOW}🧹 Cleaning up wine processes...${NC}"
    pkill -9 -f "wine.*\.exe" 2>/dev/null || true
    pkill -9 wineserver 2>/dev/null || true
    pkill -9 winedevice 2>/dev/null || true
    pkill -9 plugplay 2>/dev/null || true
    wineserver -k9 2>/dev/null || true
    sleep 3
    echo -e "${GREEN}✓ Cleanup complete${NC}"
    log "Wine processes cleaned up"
}

# ==========================================
# Smart Progress Monitoring
# ==========================================

install_with_progress_monitor() {
    local component=$1
    local description=$2
    local max_idle_time=300  # 5 minutes of NO activity = stuck
    
    log "Installing component: $component ($description)"
    
    echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📦 Installing: $description${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo "This may take 15-30 minutes. Monitoring for progress..."
    echo ""
    
    # Create a temporary log file for this component
    local temp_log="/tmp/winetricks_${component}_$$.log"
    
    # Run winetricks in background, capturing output
    WINEPREFIX="$WINEPREFIX" winetricks --unattended --force $component \
        > "$temp_log" 2>&1 &
    local pid=$!
    
    # Monitor for ACTIVITY, not just time
    local last_size=0
    local idle_count=0
    local elapsed=0
    local spinner_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local spinner_index=0
    
    while kill -0 $pid 2>/dev/null; do
        # Check if log file is growing (= progress happening)
        local current_size=$(stat -c%s "$temp_log" 2>/dev/null || echo 0)
        
        # Get spinner character
        local spinner_char=${spinner_chars:$spinner_index:1}
        spinner_index=$(( (spinner_index + 1) % 10 ))
        
        if [ "$current_size" -gt "$last_size" ]; then
            # Progress detected! Reset idle counter
            local bytes_added=$((current_size - last_size))
            idle_count=0
            last_size=$current_size
            
            # Show active progress with green spinner
            printf "\r${GREEN}${spinner_char}${NC} [%3ds] %s... ${GREEN}✓ ACTIVE${NC} (+%d bytes)     " \
                $elapsed "$description" $bytes_added
        else
            # No progress, increment idle counter
            idle_count=$((idle_count + 5))
            
            # Show idle status with yellow spinner
            printf "\r${YELLOW}${spinner_char}${NC} [%3ds] %s... ${YELLOW}⏸ IDLE${NC} (%ds)     " \
                $elapsed "$description" $idle_count
            
            # Only kill if TRULY stuck (no activity for 5+ minutes)
            if [ $idle_count -ge $max_idle_time ]; then
                echo ""
                echo -e "${YELLOW}⚠️  WARNING: No progress for $max_idle_time seconds!${NC}"
                log "WARNING: No progress for $max_idle_time seconds on $component"
                echo "This might be stuck. Checking wine processes..."
                
                # Check if wine processes are actually doing something
                if ps aux | grep -v grep | grep -q "wine.*\.exe"; then
                    echo -e "${GREEN}Wine processes still running. Giving it more time...${NC}"
                    log "Wine processes still running, continuing..."
                    idle_count=0  # Reset, give it another chance
                else
                    echo -e "${RED}❌ No wine processes found. Installation appears stuck.${NC}"
                    log "ERROR: Installation stuck, killing process"
                    kill -9 $pid 2>/dev/null
                    break
                fi
            fi
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    echo ""  # New line after progress
    echo -e "${GREEN}✓ Installation process completed${NC}"
    log "Installation process completed for $component"
    
    # Show last 20 lines of log for debugging
    echo -e "\n${YELLOW}Last output from $description:${NC}"
    tail -20 "$temp_log" | sed 's/^/  │ /'
    
    # Append to unified log
    echo "========== Component: $component ($description) ==========" >> "$LOG_FILE"
    cat "$temp_log" >> "$LOG_FILE"
    echo "========== End of $component ==========" >> "$LOG_FILE"
    
    # Remove temporary log
    rm -f "$temp_log"
    
    # Cleanup wine processes
    kill_all_wine_processes
}

# ==========================================
# Component Verification
# ==========================================

verify_component() {
    local component=$1
    log "Verifying component: $component"
    echo -ne "${YELLOW}🔍 Verifying $component...${NC} "
    
    case $component in
        dotnet35)
            # Check for .NET 3.5 (includes 2.0 and 3.0)
            if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v2.0.50727" ] || \
               [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v3.0" ] || \
               [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v3.5" ]; then
                echo -e "${GREEN}✓ VERIFIED${NC}"
                log "Component $component verified successfully"
                return 0
            fi
            # Also check 64-bit versions
            if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/v2.0.50727" ] || \
               [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/v3.0" ] || \
               [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/v3.5" ]; then
                echo -e "${GREEN}✓ VERIFIED (64-bit)${NC}"
                log "Component $component verified successfully (64-bit)"
                return 0
            fi
            ;;
        dotnet48)
            # Check for .NET 4.x (dotnet48 installs as dotnet40 in Wine)
            if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319" ] || \
               [ -f "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/mscorlib.dll" ]; then
                echo -e "${GREEN}✓ VERIFIED${NC}"
                log "Component $component verified successfully"
                return 0
            fi
            # Also check 64-bit version
            if [ -d "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/v4.0.30319" ] || \
               [ -f "$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework64/v4.0.30319/mscorlib.dll" ]; then
                echo -e "${GREEN}✓ VERIFIED (64-bit)${NC}"
                log "Component $component verified successfully (64-bit)"
                return 0
            fi
            ;;
        vcrun2022)
            if [ -f "$WINEPREFIX/drive_c/windows/system32/vcruntime140.dll" ]; then
                echo -e "${GREEN}✓ VERIFIED${NC}"
                log "Component $component verified successfully"
                return 0
            fi
            ;;
    esac
    echo -e "${YELLOW}⚠ NOT FOUND (may still work)${NC}"
    log "WARNING: Component $component not found"
    return 1
}

# ==========================================
# Installation Detection
# ==========================================

detect_installation_status() {
    log "Detecting installation status..."
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Checking Installation Status${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Check Wine prefix
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${GREEN}✓ Wine prefix found: $INSTALL_DIR${NC}"
        PREFIX_EXISTS=true
        log "Wine prefix exists"
    else
        echo -e "${YELLOW}✗ No Wine prefix found${NC}"
        PREFIX_EXISTS=false
        log "Wine prefix not found"
    fi
    
    # Check .NET installations
    echo ""
    echo -e "${YELLOW}Checking .NET Framework:${NC}"
    if [ -d "$INSTALL_DIR/drive_c/windows/Microsoft.NET/Framework/v2.0.50727" ] || \
       [ -d "$INSTALL_DIR/drive_c/windows/Microsoft.NET/Framework/v3.5" ]; then
        echo -e "  ${GREEN}✓ .NET 3.5 installed${NC}"
        DOTNET35_EXISTS=true
        log ".NET 3.5 found"
    else
        echo -e "  ${YELLOW}✗ .NET 3.5 missing${NC}"
        DOTNET35_EXISTS=false
        log ".NET 3.5 not found"
    fi
    
    if [ -d "$INSTALL_DIR/drive_c/windows/Microsoft.NET/Framework/v4.0.30319" ]; then
        echo -e "  ${GREEN}✓ .NET 4.8 installed${NC}"
        DOTNET48_EXISTS=true
        log ".NET 4.8 found"
    else
        echo -e "  ${YELLOW}✗ .NET 4.8 missing${NC}"
        DOTNET48_EXISTS=false
        log ".NET 4.8 not found"
    fi
    
    # Check vcrun2022
    if [ -f "$INSTALL_DIR/drive_c/windows/system32/vcruntime140.dll" ]; then
        echo -e "  ${GREEN}✓ Visual C++ 2022 installed${NC}"
        VCRUN_EXISTS=true
        log "vcrun2022 found"
    else
        echo -e "  ${YELLOW}✗ Visual C++ 2022 missing${NC}"
        VCRUN_EXISTS=false
        log "vcrun2022 not found"
    fi
    
    # Check Affinity apps
    echo ""
    echo -e "${YELLOW}Checking Affinity Applications:${NC}"
    if [ -f "$INSTALL_DIR/drive_c/Program Files/Affinity/Photo 2/Photo.exe" ]; then
        echo -e "  ${GREEN}✓ Affinity Photo installed${NC}"
        PHOTO_EXISTS=true
        log "Affinity Photo found"
    else
        echo -e "  ${YELLOW}✗ Affinity Photo not installed${NC}"
        PHOTO_EXISTS=false
        log "Affinity Photo not found"
    fi
    
    if [ -f "$INSTALL_DIR/drive_c/Program Files/Affinity/Designer 2/Designer.exe" ]; then
        echo -e "  ${GREEN}✓ Affinity Designer installed${NC}"
        DESIGNER_EXISTS=true
        log "Affinity Designer found"
    else
        echo -e "  ${YELLOW}✗ Affinity Designer not installed${NC}"
        DESIGNER_EXISTS=false
        log "Affinity Designer not found"
    fi
    
    if [ -f "$INSTALL_DIR/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe" ]; then
        echo -e "  ${GREEN}✓ Affinity Publisher installed${NC}"
        PUBLISHER_EXISTS=true
        log "Affinity Publisher found"
    else
        echo -e "  ${YELLOW}✗ Affinity Publisher not installed${NC}"
        PUBLISHER_EXISTS=false
        log "Affinity Publisher not found"
    fi
    
    echo ""
}

# ==========================================
# Component Installation
# ==========================================

install_missing_components() {
    log "Starting component installation..."
    log "Following official Affinity Linux guide installation steps"
    
    # STEP 0: Verify winetricks is available
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Checking for Winetricks${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if ! check_winetricks; then
        echo -e "${YELLOW}⚠ Winetricks not found!${NC}"
        log "Winetricks not found, attempting installation"
        
        if ! install_winetricks; then
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}❌ CRITICAL: Winetricks installation failed${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "Winetricks is required to install dependencies."
            echo "Please install it manually and run this script again."
            echo ""
            log "ERROR: Winetricks installation failed"
            exit 1
        fi
    else
        echo -e "${GREEN}✓ Winetricks found${NC}"
        log "Winetricks is available"
    fi
    
    echo ""
    
    # STEP 1: Initialize Wine prefix with wineboot --init
    if [ ! -d "$WINEPREFIX" ]; then
        next_step
        echo -e "${YELLOW}🍷 Creating Wine prefix...${NC}"
        log "Creating Wine prefix at $WINEPREFIX"
        
        # Initialize Wine prefix (official method)
        WINEPREFIX="$WINEPREFIX" wineboot --init 2>&1 | tee -a "$LOG_FILE"
        sleep 3
        
        echo -e "${GREEN}✓ Wine prefix created${NC}"
        log "Wine prefix created successfully"
    else
        echo -e "${GREEN}✓ Wine prefix already exists${NC}"
        log "Wine prefix already exists"
    fi
    
    # STEP 2: Install all dependencies with winetricks in ONE command
    # Official command: winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11 webview2
    # Note: webview2 is required for Affinity V3 (needed for WebView2 Runtime)
    next_step
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Installing Affinity Dependencies${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Installing: remove_mono vcrun2022 dotnet48 corefonts win11 webview2${NC}"
    echo -e "${YELLOW}This may take 30-45 minutes. Please be patient...${NC}"
    echo ""
    log "Installing all dependencies with winetricks"
    
    # Create a temporary log file
    local temp_log="/tmp/winetricks_affinity_$$.log"
    
    # Run the official winetricks command
    WINEPREFIX="$WINEPREFIX" winetricks --unattended --force remove_mono vcrun2022 dotnet48 corefonts win11 webview2 \
        > "$temp_log" 2>&1 &
    local pid=$!
    
    # Monitor progress
    local last_size=0
    local idle_count=0
    local elapsed=0
    local spinner_chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local spinner_index=0
    
    while kill -0 $pid 2>/dev/null; do
        local current_size=$(stat -c%s "$temp_log" 2>/dev/null || echo 0)
        local spinner_char=${spinner_chars:$spinner_index:1}
        spinner_index=$(( (spinner_index + 1) % 10 ))
        
        if [ "$current_size" -gt "$last_size" ]; then
            local bytes_added=$((current_size - last_size))
            idle_count=0
            last_size=$current_size
            printf "\r${GREEN}${spinner_char}${NC} [%3ds] Installing dependencies... ${GREEN}✓ ACTIVE${NC} (+%d bytes)     " \
                $elapsed $bytes_added
        else
            idle_count=$((idle_count + 5))
            printf "\r${YELLOW}${spinner_char}${NC} [%3ds] Installing dependencies... ${YELLOW}⏸ IDLE${NC} (%ds)     " \
                $elapsed $idle_count
            
            # Only kill if truly stuck (10 minutes of no activity)
            if [ $idle_count -ge 600 ]; then
                if ps aux | grep -v grep | grep -q "wine.*\.exe"; then
                    echo -e "\n${GREEN}Wine processes still running, continuing...${NC}"
                    log "Wine processes still running, continuing..."
                    idle_count=0
                else
                    echo -e "\n${RED}❌ Installation appears stuck${NC}"
                    log "ERROR: Installation stuck, killing process"
                    kill -9 $pid 2>/dev/null
                    break
                fi
            fi
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    echo ""
    echo -e "${GREEN}✓ Winetricks process completed${NC}"
    log "Winetricks process completed"
    
    # Show last 30 lines of log
    echo -e "\n${YELLOW}Last output:${NC}"
    tail -30 "$temp_log" | sed 's/^/  │ /'
    
    # Append to unified log
    echo "========== Winetricks Installation (Official Method) ==========" >> "$LOG_FILE"
    cat "$temp_log" >> "$LOG_FILE"
    echo "========== End of Winetricks Installation ==========" >> "$LOG_FILE"
    
    rm -f "$temp_log"
    
    # Cleanup wine processes
    kill_all_wine_processes
    
    # STEP 3: Verify critical components
    next_step
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Verifying Installation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local critical_failed=false
    
    # Verify vcrun2022
    echo -ne "${YELLOW}Checking Visual C++ 2022...${NC} "
    if verify_component vcrun2022 2>/dev/null; then
        log "vcrun2022 verified successfully"
    else
        echo -e "${RED}✗ FAILED${NC}"
        log "ERROR: vcrun2022 verification failed"
        critical_failed=true
    fi
    
    # Verify dotnet48
    echo -ne "${YELLOW}Checking .NET 4.8...${NC} "
    if verify_component dotnet48 2>/dev/null; then
        log "dotnet48 verified successfully"
    else
        echo -e "${YELLOW}⚠ NOT FOUND${NC}"
        log "WARNING: dotnet48 verification failed (may still work)"
    fi
    
    # Check Windows version
    echo -ne "${YELLOW}Checking Windows version...${NC} "
    local win_version=$(WINEPREFIX="$WINEPREFIX" wine reg query 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion 2>/dev/null | grep -i "CurrentVersion" | awk '{print $NF}' | tr -d '\r')
    
    if [ "$win_version" = "10.0" ]; then
        echo -e "${GREEN}✓ (Windows 11)${NC}"
        log "Windows version: 11 (10.0)"
    else
        echo -e "${YELLOW}⚠ ($win_version - expected 10.0)${NC}"
        log "WARNING: Windows version is $win_version (expected 10.0)"
    fi
    
    echo ""
    
    # Stop if critical components failed
    if [ "$critical_failed" = true ]; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ CRITICAL: Some components failed to install${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "What would you like to do?"
        echo "  1) Continue anyway (Affinity might not work)"
        echo "  2) Retry installation"
        echo "  3) Exit and check logs"
        echo ""
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                log "User chose to continue despite failures"
                echo -e "${YELLOW}Continuing...${NC}"
                ;;
            2)
                log "User chose to retry installation"
                echo -e "${YELLOW}Retrying...${NC}"
                install_missing_components
                return
                ;;
            3)
                log "User chose to exit"
                echo -e "${CYAN}Check the log file: $LOG_FILE${NC}"
                exit 1
                ;;
            *)
                echo -e "${YELLOW}Invalid choice, continuing anyway...${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}✓ All critical components verified${NC}"
        log "All critical components verified successfully"
    fi
    
    log "Component installation completed"
}

# ==========================================
# Download Helper Files
# ==========================================

download_helper_files() {
    log "Downloading helper files..."
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📥 Downloading Required Helper Files${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local temp_dir="/tmp"
    
    # Download wintypes.dll
    echo -e "${YELLOW}Downloading wintypes.dll...${NC}"
    log "Downloading wintypes.dll"
    
    if command -v curl &> /dev/null; then
        curl --output "$temp_dir/wintypes.dll" --follow --location \
            "https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so" 2>&1 | tee -a "$LOG_FILE"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/wintypes.dll" \
            "https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity/raw/refs/heads/master/wintypes_shim.dll.so" 2>&1 | tee -a "$LOG_FILE"
    else
        echo -e "${RED}✗ Neither curl nor wget found${NC}"
        log "ERROR: Neither curl nor wget available"
        return 1
    fi
    
    if [ -f "$temp_dir/wintypes.dll" ]; then
        echo -e "${GREEN}✓ wintypes.dll downloaded${NC}"
        log "wintypes.dll downloaded successfully"
    else
        echo -e "${RED}✗ Failed to download wintypes.dll${NC}"
        log "ERROR: Failed to download wintypes.dll"
        return 1
    fi
    
    # Download Windows.winmd
    echo -e "${YELLOW}Downloading Windows.winmd...${NC}"
    log "Downloading Windows.winmd"
    
    if command -v curl &> /dev/null; then
        curl --output "$temp_dir/Windows.winmd" --follow --location \
            "https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd" 2>&1 | tee -a "$LOG_FILE"
    elif command -v wget &> /dev/null; then
        wget -O "$temp_dir/Windows.winmd" \
            "https://github.com/microsoft/windows-rs/raw/master/crates/libs/bindgen/default/Windows.winmd" 2>&1 | tee -a "$LOG_FILE"
    else
        echo -e "${RED}✗ Neither curl nor wget found${NC}"
        log "ERROR: Neither curl nor wget available"
        return 1
    fi
    
    if [ -f "$temp_dir/Windows.winmd" ]; then
        echo -e "${GREEN}✓ Windows.winmd downloaded${NC}"
        log "Windows.winmd downloaded successfully"
    else
        echo -e "${RED}✗ Failed to download Windows.winmd${NC}"
        log "ERROR: Failed to download Windows.winmd"
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}✓ All helper files downloaded${NC}"
    log "All helper files downloaded successfully"
    
    # Store paths for later use
    WINTYPES_DLL="$temp_dir/wintypes.dll"
    WINDOWS_WINMD="$temp_dir/Windows.winmd"
    
    return 0
}

# ==========================================
# Desktop Shortcut Creation
# ==========================================

create_desktop_shortcuts() {
    log "Creating desktop shortcuts..."
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔗 Creating Application Menu Shortcuts${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Create applications directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/icons"
    
    # Download icons
    echo -e "${YELLOW}📥 Downloading application icons...${NC}"
    log "Downloading application icons"
    
    # Function to download with curl or wget
    download_icon() {
        local url="$1"
        local output="$2"
        
        if command -v curl &> /dev/null; then
            curl --output "$output" --location --silent "$url" 2>&1 | tee -a "$LOG_FILE" || true
        elif command -v wget &> /dev/null; then
            wget -q -O "$output" "$url" 2>&1 | tee -a "$LOG_FILE" || true
        else
            echo -e "${YELLOW}⚠ Neither curl nor wget found, skipping icon download${NC}"
            log "WARNING: Neither curl nor wget available for icon download"
            return 1
        fi
    }
    
    download_icon "https://upload.wikimedia.org/wikipedia/commons/f/f5/Affinity_Photo_V2_icon.svg" \
        "$HOME/.local/share/icons/AffinityPhoto.svg"
    
    download_icon "https://upload.wikimedia.org/wikipedia/commons/3/3c/Affinity_Designer_2-logo.svg" \
        "$HOME/.local/share/icons/AffinityDesigner.svg"
    
    download_icon "https://upload.wikimedia.org/wikipedia/commons/9/9c/Affinity_Publisher_V2_icon.svg" \
        "$HOME/.local/share/icons/AffinityPublisher.svg"
    
    # Download V3 icon (new unified app) - using correct Wikipedia URL
    download_icon "https://upload.wikimedia.org/wikipedia/commons/c/cf/Affinity_%28App%29_Logo.svg" \
        "$HOME/.local/share/icons/Affinity.svg"
    
    echo -e "${GREEN}✓ Icons downloaded${NC}"
    log "Icons downloaded successfully"
    
    # Detect which Affinity apps are installed
    echo -e "${YELLOW}Scanning for installed Affinity applications...${NC}"
    log "Scanning for Affinity apps"
    
    # First, try to find Affinity V3 (unified app) - it can be in various locations
    local affinity_v3_exe=""
    
    # Check common V3 installation paths
    if [ -f "$WINEPREFIX/drive_c/Program Files/Affinity/Affinity.exe" ]; then
        affinity_v3_exe="$WINEPREFIX/drive_c/Program Files/Affinity/Affinity.exe"
        echo -e "${GREEN}✓ Found Affinity V3 at: Program Files/Affinity/${NC}"
    elif [ -f "$WINEPREFIX/drive_c/Program Files (x86)/Affinity/Affinity.exe" ]; then
        affinity_v3_exe="$WINEPREFIX/drive_c/Program Files (x86)/Affinity/Affinity.exe"
        echo -e "${GREEN}✓ Found Affinity V3 at: Program Files (x86)/Affinity/${NC}"
    else
        # Search for Affinity.exe anywhere in drive_c
        echo -e "${YELLOW}Searching for Affinity.exe in Wine prefix...${NC}"
        affinity_v3_exe=$(find "$WINEPREFIX/drive_c" -name "Affinity.exe" 2>/dev/null | head -1)
        if [ -n "$affinity_v3_exe" ]; then
            echo -e "${GREEN}✓ Found Affinity V3 at: $(dirname "$affinity_v3_exe")${NC}"
        fi
    fi
    
    # Create V3 shortcut if found
    if [ -n "$affinity_v3_exe" ] && [ -f "$affinity_v3_exe" ]; then
        echo -e "${YELLOW}Creating shortcut for Affinity V3 (Unified App)...${NC}"
        log "Creating desktop shortcut for Affinity V3: $affinity_v3_exe"
        
        cat > "$HOME/.local/share/applications/Affinity.desktop" << EOF
[Desktop Entry]
Name=Affinity
Comment=Unified Affinity application for photo editing, design, and publishing
Icon=${HOME}/.local/share/icons/Affinity.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_v3_exe"
Terminal=false
Type=Application
Categories=Graphics;
StartupNotify=true
StartupWMClass=affinity.exe
EOF
        chmod +x "$HOME/.local/share/applications/Affinity.desktop"
        echo -e "${GREEN}✓ Affinity V3 shortcut created${NC}"
        log "Affinity V3 desktop shortcut created"
    fi
    
    # Also check for V2 apps
    local affinity_dir="$WINEPREFIX/drive_c/Program Files/Affinity"
    if [ ! -d "$affinity_dir" ]; then
        if [ -z "$affinity_v3_exe" ]; then
            echo -e "${YELLOW}⚠ No Affinity installation found${NC}"
            log "WARNING: No Affinity installation detected"
        fi
        return 0
    fi
    
    echo -e "${YELLOW}Checking for Affinity V3 app...${NC}"
    ls -la "$affinity_dir" 2>&1 | tee -a "$LOG_FILE"
    
    # Check for Affinity Photo
    if [ -f "$affinity_dir/Photo 2/Photo.exe" ]; then
        echo -e "${YELLOW}Creating shortcut for Affinity Photo...${NC}"
        log "Creating desktop shortcut for Affinity Photo"
        
        cat > "$HOME/.local/share/applications/AffinityPhoto.desktop" << EOF
[Desktop Entry]
Name=Affinity Photo
Comment=Professional photo editing software
Icon=$HOME/.local/share/icons/AffinityPhoto.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_dir/Photo 2/Photo.exe"
Terminal=false
Type=Application
Categories=Graphics;Photography;
StartupNotify=true
StartupWMClass=photo.exe
EOF
        chmod +x "$HOME/.local/share/applications/AffinityPhoto.desktop"
        echo -e "${GREEN}✓ Affinity Photo shortcut created${NC}"
        log "Affinity Photo desktop shortcut created"
    fi
    
    # Check for Affinity Designer
    if [ -f "$affinity_dir/Designer 2/Designer.exe" ]; then
        echo -e "${YELLOW}Creating shortcut for Affinity Designer...${NC}"
        log "Creating desktop shortcut for Affinity Designer"
        
        cat > "$HOME/.local/share/applications/AffinityDesigner.desktop" << EOF
[Desktop Entry]
Name=Affinity Designer
Comment=Professional vector graphic design software
Icon=$HOME/.local/share/icons/AffinityDesigner.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_dir/Designer 2/Designer.exe"
Terminal=false
Type=Application
Categories=Graphics;VectorGraphics;
StartupNotify=true
StartupWMClass=designer.exe
EOF
        chmod +x "$HOME/.local/share/applications/AffinityDesigner.desktop"
        echo -e "${GREEN}✓ Affinity Designer shortcut created${NC}"
        log "Affinity Designer desktop shortcut created"
    fi
    
    # Check for Affinity Publisher
    if [ -f "$affinity_dir/Publisher 2/Publisher.exe" ]; then
        echo -e "${YELLOW}Creating shortcut for Affinity Publisher...${NC}"
        log "Creating desktop shortcut for Affinity Publisher"
        
        cat > "$HOME/.local/share/applications/AffinityPublisher.desktop" << EOF
[Desktop Entry]
Name=Affinity Publisher
Comment=Professional desktop publishing software
Icon=$HOME/.local/share/icons/AffinityPublisher.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_dir/Publisher 2/Publisher.exe"
Terminal=false
Type=Application
Categories=Graphics;Publishing;
StartupNotify=true
StartupWMClass=publisher.exe
EOF
        chmod +x "$HOME/.local/share/applications/AffinityPublisher.desktop"
        echo -e "${GREEN}✓ Affinity Publisher shortcut created${NC}"
        log "Affinity Publisher desktop shortcut created"
    fi
    
    # Check for unified Affinity app (V3)
    if [ -f "$affinity_dir/Affinity/Affinity.exe" ]; then
        echo -e "${YELLOW}Creating shortcut for Affinity (Unified App)...${NC}"
        log "Creating desktop shortcut for Affinity unified app"
        
        cat > "$HOME/.local/share/applications/Affinity.desktop" << EOF
[Desktop Entry]
Name=Affinity
Comment=Unified Affinity application for photo editing, design, and publishing
Icon=$HOME/.local/share/icons/Affinity.svg
Path=$WINEPREFIX
Exec=env WINEPREFIX="$WINEPREFIX" wine "$affinity_dir/Affinity/Affinity.exe"
Terminal=false
Type=Application
Categories=Graphics;
StartupNotify=true
StartupWMClass=affinity.exe
EOF
        chmod +x "$HOME/.local/share/applications/Affinity.desktop"
        echo -e "${GREEN}✓ Affinity (Unified) shortcut created${NC}"
        log "Affinity unified app desktop shortcut created"
    fi
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        echo -e "${YELLOW}Updating desktop database...${NC}"
        update-desktop-database "$HOME/.local/share/applications" 2>&1 | tee -a "$LOG_FILE" || true
        echo -e "${GREEN}✓ Desktop database updated${NC}"
        log "Desktop database updated"
    fi
    
    echo ""
    echo -e "${GREEN}✓ Desktop shortcuts created successfully Icon might not be visible !${NC}"
    echo -e "${CYAN}ℹ  You can now find Affinity apps in your application menu${NC}"
    log "Desktop shortcuts creation completed"
    
    return 0
}

# ==========================================
# Install Affinity Application
# ==========================================

install_affinity_app() {
    log "Starting Affinity application installation..."
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🎨 Install Affinity Application${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    echo -e "${YELLOW}Affinity V3 Installer Information:${NC}"
    echo ""
    echo "Affinity V3 has TWO installer types:"
    echo "  1. ${GREEN}Enterprise (.exe)${NC} - Recommended for Wine/Linux"
    echo "  2. ${YELLOW}MSIX (.msix)${NC} - Requires extraction"
    echo ""
    echo -e "${GREEN}✓ Recommended: Download the Enterprise (.exe) installer${NC}"
    echo "  Available at: https://store.serif.com/account/licences/"
    echo "  Look for 'Enterprise' or 'Offline' installer option"
    echo ""
    echo -e "${YELLOW}If you only have .msix, the script will extract it automatically.${NC}"
    echo ""
    
    echo -e "${YELLOW}Please provide the path to your Affinity installer:${NC}"
    echo -e "${YELLOW}Drag and drop the file here, or type the full path:${NC}"
    
    read -r installer_path
    
    # Remove quotes if present (both double and single quotes)
    installer_path="${installer_path%\"}"
    installer_path="${installer_path#\"}"
    installer_path="${installer_path%\'}"
    installer_path="${installer_path#\'}"
    
    # Expand ~ to home directory
    installer_path="${installer_path/#\~/$HOME}"
    
    # Check if file exists
    if [ ! -f "$installer_path" ]; then
        echo -e "${RED}✗ File not found: $installer_path${NC}"
        log "ERROR: Installer file not found: $installer_path"
        echo ""
        echo "Would you like to:"
        echo "  1) Try again with a different path"
        echo "  2) Skip installer and finish setup"
        echo ""
        read -p "Enter choice (1-2): " choice
        
        case $choice in
            1)
                install_affinity_app
                return
                ;;
            2)
                echo -e "${YELLOW}Skipping installer...${NC}"
                log "User skipped Affinity installer"
                return 0
                ;;
        esac
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}✓ Found installer: $(basename "$installer_path")${NC}"
    log "Found installer: $installer_path"
    
    # Check file type
    if [[ "$installer_path" =~ \.exe$ ]]; then
        # .exe installer - direct installation
        echo -e "${GREEN}✓ Enterprise .exe installer detected${NC}"
        log "Using .exe installer"
        
        echo ""
        echo -e "${YELLOW}Running Affinity installer...${NC}"
        echo -e "${YELLOW}This will open a graphical installer window.${NC}"
        echo -e "${YELLOW}Follow the on-screen instructions to complete installation.${NC}"
        echo ""
        log "Running Affinity .exe installer: $installer_path"
        
        WINEPREFIX="$WINEPREFIX" wine "$installer_path" 2>&1 | tee -a "$LOG_FILE"
        
        # Create desktop shortcuts immediately after installer finishes
        echo ""
        echo -e "${CYAN}Creating desktop shortcuts...${NC}"
        create_desktop_shortcuts
        
    elif [[ "$installer_path" =~ \.msix$ ]]; then
        # .msix installer - needs extraction
        echo -e "${YELLOW}⚠ MSIX installer detected${NC}"
        log "Using .msix installer (requires extraction)"
        
        echo ""
        echo -e "${YELLOW}MSIX files need to be extracted first.${NC}"
        echo -e "${YELLOW}Extracting MSIX package...${NC}"
        
        # Create temp directory for extraction
        local extract_dir="/tmp/affinity_msix_$$"
        mkdir -p "$extract_dir"
        
        # Extract MSIX (it's a ZIP archive)
        if command -v 7z &> /dev/null; then
            echo -e "${YELLOW}Using 7z to extract...${NC}"
            7z x "$installer_path" -o"$extract_dir" 2>&1 | tee -a "$LOG_FILE"
        elif command -v unzip &> /dev/null; then
            echo -e "${YELLOW}Using unzip to extract...${NC}"
            unzip -q "$installer_path" -d "$extract_dir" 2>&1 | tee -a "$LOG_FILE"
        else
            echo -e "${RED}✗ No extraction tool found (need 7z or unzip)${NC}"
            echo "Install with: sudo apt install p7zip-full"
            log "ERROR: No extraction tool available"
            rm -rf "$extract_dir"
            return 1
        fi
        
        echo -e "${GREEN}✓ MSIX extracted${NC}"
        log "MSIX extracted to $extract_dir"
        
        # Manual installation - copy files directly (installer is broken in Wine)
        echo ""
        echo -e "${YELLOW}📦 Installing Affinity V3 (Manual Installation)${NC}"
        echo -e "${YELLOW}Bypassing broken installer - copying files directly...${NC}"
        log "Using manual installation method for MSIX"
        
        # Check if App directory exists
        if [ ! -d "$extract_dir/App" ]; then
            echo -e "${RED}✗ App directory not found in MSIX package${NC}"
            log "ERROR: App directory not found in MSIX"
            rm -rf "$extract_dir"
            return 1
        fi
        
        # Create Affinity installation directory
        local affinity_install_dir="$WINEPREFIX/drive_c/Program Files/Affinity"
        echo -e "${YELLOW}Creating installation directory...${NC}"
        mkdir -p "$affinity_install_dir"
        log "Created installation directory: $affinity_install_dir"
        
        # Copy all files from App directory
        echo -e "${YELLOW}Copying Affinity files (this may take a few minutes)...${NC}"
        cp -r "$extract_dir/App/"* "$affinity_install_dir/" 2>&1 | tee -a "$LOG_FILE"
        
        # Verify installation
        if [ -f "$affinity_install_dir/Affinity.exe" ]; then
            echo -e "${GREEN}✓ Affinity files copied successfully${NC}"
            echo -e "${GREEN}✓ Found: Affinity.exe ($(du -h "$affinity_install_dir/Affinity.exe" | cut -f1))${NC}"
            log "Affinity.exe installed at: $affinity_install_dir/Affinity.exe"
            
            # Create desktop shortcuts
            echo ""
            echo -e "${CYAN}Creating desktop shortcuts...${NC}"
            create_desktop_shortcuts
        else
            echo -e "${RED}✗ Installation failed - Affinity.exe not found${NC}"
            log "ERROR: Affinity.exe not found after manual installation"
            rm -rf "$extract_dir"
            return 1
        fi
        
        # Cleanup
        rm -rf "$extract_dir"
        
    else
        echo -e "${RED}✗ File must be a .exe or .msix installer${NC}"
        log "ERROR: File is not .exe or .msix: $installer_path"
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}✓ Installer completed${NC}"
    log "Affinity installer completed"
    
    # Copy helper files to Affinity directory
    echo ""
    echo -e "${YELLOW}Copying helper files to Affinity directory...${NC}"
    log "Copying helper files"
    
    # Find Affinity installation directory
    local affinity_dir="$WINEPREFIX/drive_c/Program Files/Affinity"
    
    if [ -d "$affinity_dir" ]; then
        # Find the actual Affinity subdirectory (Photo, Designer, Publisher, or just "Affinity")
        local app_dir=$(find "$affinity_dir" -maxdepth 1 -type d \( -name "Affinity*" -o -name "Affinity" \) | head -1)
        
        if [ -n "$app_dir" ]; then
            echo -e "${YELLOW}Copying wintypes.dll to: $app_dir${NC}"
            cp "$WINTYPES_DLL" "$app_dir/" 2>&1 | tee -a "$LOG_FILE"
            echo -e "${GREEN}✓ wintypes.dll copied${NC}"
            log "wintypes.dll copied to $app_dir"
        else
            echo -e "${YELLOW}⚠ Could not find Affinity app directory${NC}"
            echo -e "${YELLOW}You may need to copy wintypes.dll manually to:${NC}"
            echo "  $affinity_dir/Affinity/"
            log "WARNING: Could not find Affinity app directory"
        fi
    else
        echo -e "${YELLOW}⚠ Affinity directory not found${NC}"
        echo -e "${YELLOW}You may need to copy wintypes.dll manually${NC}"
        log "WARNING: Affinity directory not found"
    fi
    
    # Copy Windows.winmd to WinMetadata directory
    local winmetadata_dir="$WINEPREFIX/drive_c/windows/system32/WinMetadata"
    mkdir -p "$winmetadata_dir"
    
    echo -e "${YELLOW}Copying Windows.winmd to: $winmetadata_dir${NC}"
    cp "$WINDOWS_WINMD" "$winmetadata_dir/" 2>&1 | tee -a "$LOG_FILE"
    echo -e "${GREEN}✓ Windows.winmd copied${NC}"
    log "Windows.winmd copied to $winmetadata_dir"
    
    echo ""
    echo -e "${GREEN}✓ Helper files installed${NC}"
    log "Helper files installed successfully"
    
    # Create desktop shortcuts for installed Affinity apps
    create_desktop_shortcuts
    
    return 0
}

# ==========================================
# Final Verification
# ==========================================

final_verification() {
    log "Starting final verification..."
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔍 Final Verification${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    local all_good=true
    
    # Verify Wine prefix
    echo -ne "${YELLOW}Wine Prefix...${NC} "
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${GREEN}✓${NC}"
        log "Final verification: Wine prefix OK"
    else
        echo -e "${RED}✗${NC}"
        log "Final verification: Wine prefix FAILED"
        all_good=false
    fi
    
    # Verify .NET 3.5
    echo -ne "${YELLOW}.NET 3.5...${NC} "
    if verify_component dotnet35 2>/dev/null; then
        log "Final verification: .NET 3.5 OK"
    else
        log "Final verification: .NET 3.5 FAILED"
        all_good=false
    fi
    
    # Verify vcrun2022
    echo -ne "${YELLOW}Visual C++ 2022...${NC} "
    if verify_component vcrun2022 2>/dev/null; then
        log "Final verification: vcrun2022 OK"
    else
        log "Final verification: vcrun2022 FAILED"
        all_good=false
    fi
    
    # Verify .NET 4.8
    echo -ne "${YELLOW}.NET 4.8...${NC} "
    if verify_component dotnet48 2>/dev/null; then
        log "Final verification: .NET 4.8 OK"
    else
        log "Final verification: .NET 4.8 FAILED"
        all_good=false
    fi
    
    # Check Windows version
    echo -ne "${YELLOW}Windows Version...${NC} "
    # Use proper wine reg query command
    local win_version=$(WINEPREFIX="$WINEPREFIX" wine reg query 'HKLM\Software\Microsoft\Windows NT\CurrentVersion' /v CurrentVersion 2>/dev/null | grep -i "CurrentVersion" | awk '{print $NF}' | tr -d '\r')
    
    if [ -z "$win_version" ]; then
        # Fallback method
        win_version=$(WINEPREFIX="$WINEPREFIX" wine regedit /E /tmp/winver.reg 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion' 2>/dev/null && grep "CurrentVersion" /tmp/winver.reg | cut -d'"' -f4 | tr -d '\r')
    fi
    
    if [ "$win_version" = "10.0" ]; then
        echo -e "${GREEN}✓ (Windows 11)${NC}"
        log "Final verification: Windows version OK (11)"
    elif [ -n "$win_version" ]; then
        echo -e "${YELLOW}⚠ ($win_version - should be 10.0)${NC}"
        log "Final verification: Windows version is $win_version (expected 10.0)"
    else
        echo -e "${YELLOW}⚠ (Could not detect)${NC}"
        log "Final verification: Could not detect Windows version"
    fi
    
    echo ""
    
    if [ "$all_good" = true ]; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✓ All components verified successfully!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        log "Final verification: ALL PASSED"
    else
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}⚠ Some components may need attention${NC}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        log "Final verification: SOME FAILED"
    fi
    
    echo ""
    echo -e "${CYAN}📝 Full installation log: $LOG_FILE${NC}"
    log "Final verification completed"
}

# ==========================================
# Main Installation Flow
# ==========================================

main() {
    clear
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}   Affinity Linux Installation Script - ENHANCED${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    log "=========================================="
    log "Affinity Linux Installation Started"
    log "=========================================="
    
    # Check Wine first
    echo -e "${YELLOW}Checking Wine installation...${NC}"
    if ! check_wine_version; then
        echo -e "${YELLOW}⚠ Wine 10.0+ is required but not found${NC}"
        echo -e "${CYAN}Installing Wine 10.0+ automatically...${NC}"
        log "Wine 10.0+ not found, installing automatically"
        
        install_wine || {
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}❌ Failed to install Wine 10.0+${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "Please install Wine 10.0+ manually and run this script again."
            echo ""
            echo "Installation guides:"
            echo "  Ubuntu/Debian: https://wiki.winehq.org/Ubuntu"
            echo "  Arch: sudo pacman -S wine"
            echo "  Fedora: https://wiki.winehq.org/Fedora"
            echo ""
            log "Wine installation failed, exiting"
            exit 1
        }
        
        echo -e "${GREEN}✓ Wine 10.0+ installed successfully${NC}"
        log "Wine 10.0+ installed successfully"
    else
        echo -e "${GREEN}✓ Wine 10.0+ found${NC}"
        log "Wine 10.0+ found"
    fi
    
    # Detect existing installation
    detect_installation_status
    
    # Show main menu
    if [ "$PREFIX_EXISTS" = true ]; then
        options=(
            "1️⃣  Continue/Resume Installation"
            "2️⃣  Install Affinity (.exe or .msix)"
            "3️⃣  Delete Everything and Fresh Install"
            "4️⃣  Exit"
        )
        show_menu "Existing Installation Detected" "${options[@]}"
        choice=$?
        
        case $choice in
            0) # Continue
                log "User selected: Continue/Resume"
                INSTALL_MODE="continue"
                ;;
            1) # Install Affinity directly
                log "User selected: Install Affinity"
                
                # Download helper files first
                download_helper_files || {
                    echo -e "${YELLOW}Warning: Helper files download failed${NC}"
                    echo "You can download them manually later."
                }
                
                # Install Affinity
                install_affinity_app
                
                # Create desktop shortcuts for the installed app
                create_desktop_shortcuts
                
                # Exit after installation
                echo ""
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${GREEN}✓ Affinity Installation Complete!${NC}"
                echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                echo -e "${CYAN}📝 Installation log saved to: $LOG_FILE${NC}"
                echo ""
                log "Affinity installation completed from menu"
                exit 0
                ;;
            2) # Delete and fresh install
                log "User selected: Delete and fresh install"
                echo ""
                echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo -e "${RED}⚠️  WARNING: This will DELETE everything!${NC}"
                echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo ""
                read -p "Type 'DELETE' to confirm: " confirm
                
                if [ "$confirm" = "DELETE" ]; then
                    backup_dir="$INSTALL_DIR.backup.$(date +%Y%m%d_%H%M%S)"
                    echo -e "${YELLOW}Creating backup...${NC}"
                    mv "$INSTALL_DIR" "$backup_dir"
                    echo -e "${GREEN}✓ Backup created: $backup_dir${NC}"
                    log "Backup created: $backup_dir"
                    INSTALL_MODE="fresh"
                else
                    echo -e "${YELLOW}Cancelled. Exiting.${NC}"
                    log "User cancelled deletion"
                    exit 0
                fi
                ;;
            3) # Exit
                log "User selected: Exit"
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
        esac
    else
        # No existing installation - show different menu
        options=(
            "1️⃣  Fresh Install (Setup Wine + Install Affinity)"
            "2️⃣  Install Affinity Only (.exe or .msix)"
            "3️⃣  Exit"
        )
        show_menu "No Installation Detected" "${options[@]}"
        choice=$?
        
        case $choice in
            0) # Fresh install (full setup)
                log "User selected: Fresh install"
                INSTALL_MODE="fresh"
                ;;
            1) # Install Affinity only
                log "User selected: Install Affinity only"
                
                # Check if Wine prefix exists
                if [ ! -d "$WINEPREFIX" ]; then
                    echo ""
                    echo -e "${YELLOW}⚠ No Wine prefix found!${NC}"
                    echo "You need to set up Wine first before installing Affinity."
                    echo ""
                    echo "Would you like to:"
                    echo "  1) Set up Wine now (recommended)"
                    echo "  2) Exit and set up manually"
                    echo ""
                    read -p "Enter choice (1-2): " setup_choice
                    
                    case $setup_choice in
                        1)
                            INSTALL_MODE="fresh"
                            ;;
                        2)
                            echo -e "${YELLOW}Exiting...${NC}"
                            exit 0
                            ;;
                        *)
                            echo -e "${YELLOW}Invalid choice, exiting...${NC}"
                            exit 0
                            ;;
                    esac
                else
                    # Wine prefix exists, just install Affinity
                    download_helper_files || {
                        echo -e "${YELLOW}Warning: Helper files download failed${NC}"
                    }
                    
                    install_affinity_app
                    
                    # Create desktop shortcuts for the installed app
                    create_desktop_shortcuts
                    
                    echo ""
                    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo -e "${GREEN}✓ Affinity Installation Complete!${NC}"
                    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                    echo ""
                    echo -e "${CYAN}📝 Installation log saved to: $LOG_FILE${NC}"
                    echo ""
                    log "Affinity installation completed from menu"
                    exit 0
                fi
                ;;
            2) # Exit
                log "User selected: Exit"
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
        esac
        
        log "No existing installation, starting fresh"
        INSTALL_MODE="fresh"
    fi
    
    # Install components
    echo ""
    echo -e "${GREEN}Starting component installation...${NC}"
    log "Starting component installation (mode: $INSTALL_MODE)"
    echo ""
    
    install_missing_components
    
    # Final verification
    final_verification
    
    # Download helper files
    download_helper_files || {
        echo -e "${RED}Failed to download helper files${NC}"
        log "ERROR: Failed to download helper files"
        echo "You can download them manually later from:"
        echo "  - wintypes.dll: https://github.com/ElementalWarrior/wine-wintypes.dll-for-affinity"
        echo "  - Windows.winmd: https://github.com/microsoft/windows-rs"
    }
    
    # Ask if user wants to install Affinity now
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🎨 Affinity Application Installation${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Do you want to install Affinity now?"
    echo "  1) Yes, I have the installer ready"
    echo "  2) No, I'll install it later"
    echo ""
    read -p "Enter choice (1-2): " install_choice
    
    case $install_choice in
        1)
            install_affinity_app || {
                echo -e "${YELLOW}Affinity installation skipped or failed${NC}"
                log "Affinity installation skipped or failed"
            }
            ;;
        2)
            echo -e "${YELLOW}Skipping Affinity installation${NC}"
            log "User chose to skip Affinity installation"
            
            # Show manual installation instructions
            echo ""
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${CYAN}📋 Manual Installation Instructions${NC}"
            echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo ""
            echo "1. Download Affinity installer (.exe) from:"
            echo "   https://store.serif.com/account/licences/"
            echo ""
            echo "2. Run the installer:"
            echo "   WINEPREFIX=$INSTALL_DIR wine /path/to/affinity_installer.exe"
            echo ""
            echo "3. Copy helper files:"
            echo "   cp /tmp/wintypes.dll \"$INSTALL_DIR/drive_c/Program Files/Affinity/Affinity/\""
            echo "   cp /tmp/Windows.winmd \"$INSTALL_DIR/drive_c/windows/system32/WinMetadata/\""
            echo ""
            echo "4. Launch Affinity:"
            echo "   WINEPREFIX=$INSTALL_DIR wine \"$INSTALL_DIR/drive_c/Program Files/Affinity/Affinity/Affinity.exe\""
            echo ""
            ;;
    esac
    
    # Final summary
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Setup Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📝 Installation log saved to: $LOG_FILE${NC}"
    echo ""
    
    echo "Shortcut Icon might not show It'll get patch in next update"
    
    log "=========================================="
    log "Affinity Linux Installation Completed"
    log "=========================================="
}

# Run main function
main

