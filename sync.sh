#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════
# sync.sh - Keep repos in sync (one-way: chezmoi → ansible fallback)
# ═══════════════════════════════════════════════════════════════════════
#
# PHILOSOPHY:
#   Chezmoi = source of truth (edit dotfiles here)
#   Ansible = provisioner + disaster recovery fallback
#
# WORKFLOW:
#   1. Edit configs in ~/.config/* (managed by chezmoi)
#   2. Run: chezmoi re-add <file>  (updates chezmoi repo)
#   3. Run: ./sync.sh             (snapshots to ansible fallback)
#
# This script NEVER modifies chezmoi - only reads from it.
# ═══════════════════════════════════════════════════════════════════════

set -e
cd ~/ansible-system

echo "═══════════════════════════════════════════════════════════════════"
echo "  SYNC: Chezmoi → Ansible (one-way snapshot for disaster recovery)"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────
# Step 1: Ensure chezmoi is committed first
# ─────────────────────────────────────────────────────────────────────────
echo "📦 [1/3] Check chezmoi status..."
if [[ -d ~/.local/share/chezmoi/.git ]]; then
    cd ~/.local/share/chezmoi
    if [[ -n $(git status --porcelain) ]]; then
        echo "   ⚠️  Uncommitted changes in chezmoi!"
        echo "   Run these first:"
        echo "     cd ~/.local/share/chezmoi"
        echo "     git add -A && git commit -m 'your message' && git push"
        echo ""
        read -p "   Continue anyway? [y/N] " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    else
        echo "   ✅ Chezmoi repo is clean"
    fi
    cd ~/ansible-system
else
    echo "   ⚠️  Chezmoi not initialized"
fi

# ─────────────────────────────────────────────────────────────────────────
# Step 2: Update package lists
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "📦 [2/3] Updating package lists..."
pacman -Qqen > roles/packages/tasks/packages.txt
pacman -Qqem | grep -v "\-debug$" > roles/aur/tasks/aur-packages.txt
echo "   ✅ $(wc -l < roles/packages/tasks/packages.txt) official + $(wc -l < roles/aur/tasks/aur-packages.txt) AUR"

# ─────────────────────────────────────────────────────────────────────────
# Step 3: Snapshot live configs → ansible fallback (disaster recovery)
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "📁 [3/3] Snapshotting configs to ansible fallback..."

# Clean target first to avoid stale files
rm -rf files/dotfiles/*

# Core configs (from ~/.config)
configs=(
    "hypr" "waybar" "kitty" "mako" "fuzzel"
    "nvim" "btop" "fastfetch" "MangoHud"
    "ncspot" "ncmpcpp" "cava" "tmux"
    "wallust" "gtk-3.0" "gtk-4.0" "fontconfig"
    "Thunar" "nwg-displays" "systemd"
)

for cfg in "${configs[@]}"; do
    [[ -d ~/.config/$cfg ]] && cp -r ~/.config/$cfg files/dotfiles/ && echo "   ✓ $cfg"
done

# Single files
[[ -f ~/.config/starship.toml ]] && cp ~/.config/starship.toml files/dotfiles/
[[ -f ~/.config/mpd.conf ]] && cp ~/.config/mpd.conf files/dotfiles/
[[ -f ~/.zshrc ]] && cp ~/.zshrc files/dotfiles/zshrc

# Local bin scripts
mkdir -p files/dotfiles/local-bin
cp ~/.local/bin/* files/dotfiles/local-bin/ 2>/dev/null || true
rm -rf files/dotfiles/local-bin/screenshots  # Skip subdirs

# Clean any backup files that snuck in
find files/dotfiles -type f \( -name "*.backup*" -o -name "*.bak*" -o -name "nohup.out" -o -name "*.log" -o -name "*.pyc" \) -delete 2>/dev/null
find files/dotfiles -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find files/dotfiles -type d -name ".git" -exec rm -rf {} + 2>/dev/null

echo "   ✅ Fallback snapshot complete"

# ─────────────────────────────────────────────────────────────────────────
# Commit
# ─────────────────────────────────────────────────────────────────────────
echo ""
echo "📊 Changes:"
git status --short | head -20
[[ $(git status --porcelain | wc -l) -gt 20 ]] && echo "   ... and more"

if [[ -n $(git status --porcelain) ]]; then
    echo ""
    read -p "Commit ansible changes? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add -A
        git commit -m "Snapshot: $(date +%Y-%m-%d\ %H:%M)"
        git push 2>/dev/null && echo "✅ Pushed" || echo "⚠️  Committed locally"
    fi
else
    echo ""
    echo "✅ Already in sync!"
fi
