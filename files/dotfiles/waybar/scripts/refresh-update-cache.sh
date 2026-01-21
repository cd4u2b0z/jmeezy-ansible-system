#!/bin/bash
# Refresh update cache for Waybar
# Called by systemd timer

CACHE_DIR="/tmp/update-manager"
mkdir -p "$CACHE_DIR"

# Refresh pacman cache
checkupdates > "$CACHE_DIR/pacman.cache" 2>/dev/null || true

# Refresh AUR cache (if paru/yay installed)
if command -v paru &>/dev/null; then
    paru -Qua > "$CACHE_DIR/aur.cache" 2>/dev/null || true
elif command -v yay &>/dev/null; then
    yay -Qua > "$CACHE_DIR/aur.cache" 2>/dev/null || true
fi

# Refresh flatpak cache
if command -v flatpak &>/dev/null; then
    flatpak remote-ls --updates > "$CACHE_DIR/flatpak.cache" 2>/dev/null || true
fi

# Signal waybar to refresh
pkill -SIGRTMIN+8 waybar 2>/dev/null || true
