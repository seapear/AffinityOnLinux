#!/bin/bash
# Complete setup and launcher for Affinity Installer - Unified Version
# This script sets up the environment and launches the unified installer
# Supports: Ubuntu/Debian, Fedora, Arch
# Version V4

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "Affinity Installer - Unified Version"
echo "=========================================="
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Error: This script only works on Linux"
    exit 1
fi

# Detect distribution
echo "Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    echo "Error: Cannot detect distribution"
    exit 1
fi

echo "✓ Detected: $DISTRO"
echo ""

# Install Python3 and dependencies based on distribution
if ! command -v python3 &> /dev/null; then
    echo "Python3 not found. Installing..."
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop|zorin)
            sudo apt update
            sudo apt install -y python3 python3-venv python3-pip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y python3 python3-pip
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -S --needed --noconfirm python python-pip
            ;;
        *)
            echo "Error: Unsupported distribution: $DISTRO"
            exit 1
            ;;
    esac
    
    echo "✓ Python3 installed"
else
    echo "✓ Python3 found: $(python3 --version)"
fi

# Check if python3-venv is available
if ! python3 -m venv --help &> /dev/null; then
    echo "Installing python3-venv..."
    
    # Detect Python version
    PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
    
    echo "Detected Python version: $PYTHON_VERSION"
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop|zorin)
            # Try version-specific package first, fall back to generic
            sudo apt install -y python${PYTHON_VERSION}-venv || sudo apt install -y python3-venv
            ;;
        fedora|rhel|centos)
            # Fedora includes venv in python3 package, but install just in case
            sudo dnf install -y python3-pip
            ;;
        arch|manjaro|endeavouros)
            # Arch includes venv in python package
            sudo pacman -S --needed --noconfirm python-pip
            ;;
    esac
    
    echo "✓ venv installed"
else
    echo "✓ venv already available"
fi

# Check if pip is available
if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
    echo "Installing pip..."
    
    case $DISTRO in
        ubuntu|debian|linuxmint|pop|zorin)
            sudo apt install -y python3-pip
            ;;
        fedora|rhel|centos)
            sudo dnf install -y python3-pip
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -S --needed --noconfirm python-pip
            ;;
    esac
fi

echo "✓ All Python requirements met"
echo ""

# Check and install Qt platform plugin dependencies
echo "Checking Qt dependencies..."

case $DISTRO in
    ubuntu|debian|linuxmint|pop|zorin)
        echo "Installing Qt dependencies for Debian-based system..."
        sudo apt update
        sudo apt install -y \
            libxcb-cursor0 \
            libxcb-xinerama0 \
            libxcb-icccm4 \
            libxcb-image0 \
            libxcb-keysyms1 \
            libxcb-randr0 \
            libxcb-render-util0 \
            libxcb-shape0 \
            libxkbcommon-x11-0 \
            libxcb-xfixes0
        ;;
    
    fedora|rhel|centos)
        echo "Installing Qt dependencies for Fedora/RHEL..."
        sudo dnf install -y \
            xcb-util-cursor \
            xcb-util-wm \
            xcb-util-image \
            xcb-util-keysyms \
            xcb-util-renderutil \
            libxkbcommon-x11
        ;;
    
    arch|manjaro|endeavouros)
        echo "Installing Qt dependencies for Arch-based system..."
        sudo pacman -S --needed --noconfirm \
            xcb-util-cursor \
            xcb-util-wm \
            xcb-util-image \
            xcb-util-keysyms \
            xcb-util-renderutil \
            libxkbcommon-x11
        ;;
    
    *)
        echo "⚠ Unknown distribution, skipping Qt dependencies..."
        echo "You may need to install Qt xcb dependencies manually if you encounter errors"
        ;;
esac

echo "✓ Qt dependencies installed"
echo ""

# Check if unified installer file exists
if [ ! -f "affinity_installer_unified.py" ]; then
    echo "Error: affinity_installer_unified.py not found in $SCRIPT_DIR"
    echo ""
    echo "Expected file: $SCRIPT_DIR/affinity_installer_unified.py"
    echo ""
    echo "Please ensure the unified installer is in the same directory as this script."
    exit 1
fi

echo "✓ Unified installer file found"
echo ""

# Create venv if it doesn't exist or is corrupted
if [ ! -f "venv/bin/activate" ]; then
    if [ -d "venv" ]; then
        echo "Virtual environment corrupted, removing..."
        rm -rf venv
    fi
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi
echo ""

# Activate venv
echo "Activating virtual environment..."
if [ ! -f "venv/bin/activate" ]; then
    echo "Error: venv/bin/activate not found"
    exit 1
fi
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
python -m pip install --upgrade pip --quiet

# Install PyQt6
echo "Installing PyQt6..."
if python -c "import PyQt6" 2>/dev/null; then
    echo "✓ PyQt6 already installed"
else
    echo "Installing PyQt6 (this may take a minute)..."
    pip install PyQt6
    echo "✓ PyQt6 installed"
fi
echo ""

# Make script executable
chmod +x affinity_installer_unified.py 2>/dev/null || true

echo "=========================================="
echo "Launching Affinity Installer GUI..."
echo "=========================================="
echo ""

# Run the unified installer
python3 affinity_installer_unified.py

EXIT_CODE=$?

# Deactivate when done
deactivate 2>/dev/null || true

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "✓ Installer closed successfully"
else
    echo "⚠ Installer exited with code: $EXIT_CODE"
fi

exit $EXIT_CODE
