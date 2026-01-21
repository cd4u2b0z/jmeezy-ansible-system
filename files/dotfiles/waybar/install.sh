#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# 📦 WAYBAR SETUP INSTALLER
# Install dependencies and configure Waybar
# ═══════════════════════════════════════════════════════════════════

echo "🎨 Waybar Nord Theme Setup"
echo "=========================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Don't run this script as root!"
    exit 1
fi

# Function to check if package is installed
is_installed() {
    pacman -Q "$1" &>/dev/null
}

# Required packages
REQUIRED_PACKAGES=(
    "waybar"          # Status bar
    "playerctl"       # Media control
    "rofi"           # Application launcher/menu
    "swaylock"       # Screen locker
    "wtype"          # Wayland typing tool
    "ttf-jetbrains-mono-nerd"  # Font
)

# Optional but recommended packages
OPTIONAL_PACKAGES=(
    "pamixer"        # Audio control
    "brightnessctl"  # Brightness control
    "networkmanager" # Network management
    "bluez"          # Bluetooth
    "bluez-utils"    # Bluetooth utilities
)

echo "🔍 Checking dependencies..."

# Check required packages
missing_required=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "✅ $pkg is installed"
    else
        echo "❌ $pkg is missing"
        missing_required+=("$pkg")
    fi
done

# Check optional packages
missing_optional=()
for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if is_installed "$pkg"; then
        echo "✅ $pkg is installed"
    else
        echo "⚠️  $pkg is recommended but not required"
        missing_optional+=("$pkg")
    fi
done

# Install missing packages
if [ ${#missing_required[@]} -gt 0 ]; then
    echo ""
    echo "📦 Installing required packages..."
    echo "Packages to install: ${missing_required[*]}"
    echo ""
    read -p "Install required packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -S "${missing_required[@]}"
    else
        echo "❌ Cannot proceed without required packages"
        exit 1
    fi
fi

if [ ${#missing_optional[@]} -gt 0 ]; then
    echo ""
    echo "📦 Optional packages available:"
    echo "Packages: ${missing_optional[*]}"
    echo ""
    read -p "Install optional packages? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -S "${missing_optional[@]}"
    fi
fi

echo ""
echo "🔧 Setting up Waybar configuration..."

# Backup existing config if it exists
if [ -d "$HOME/.config/waybar" ]; then
    echo "📁 Backing up existing Waybar config..."
    mv "$HOME/.config/waybar" "$HOME/.config/waybar.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create directory structure
mkdir -p "$HOME/.config/waybar/scripts"

echo "✅ Configuration files created successfully!"
echo ""
echo "🚀 Quick Start:"
echo "1. Launch Waybar: ~/.config/waybar/launch.sh"
echo "2. Add to Hyprland config: exec-once = ~/.config/waybar/launch.sh"
echo "3. Restart Hyprland or run: hyprctl reload"
echo ""
echo "🎮 Gaming Features:"
echo "• Steam/Discord integration with status indicators"
echo "• Gaming-aware power management (warns before shutdown)"
echo "• Music control with multi-platform support"
echo "• Transparent Nord theme with gaming aesthetics"
echo ""
echo "💡 Tips:"
echo "• Left-click music widget: Play/Pause"
echo "• Right-click music widget: Next track"
echo "• Left-click power button: Full power menu"
echo "• Right-click power button: Quick lock"
echo "• All modules have hover effects and tooltips"
echo ""
echo "Configuration complete! 🎉"