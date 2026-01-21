<!-- Original work by jmeezy • github.com/jmeezy • 2026 -->

# 󰣇  Arch Linux + Hyprland System Configuration

Ansible playbook for CachyOS + Hyprland system from scratch in ~30 minutes.

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=wayland&logoColor=black)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat&logo=ansible&logoColor=white)

---

## 󰠶 Table of Contents

- [Quick Start](#-quick-start)
- [Prerequisites](#-prerequisites)
- [Full Installation Guide](#-full-installation-guide)
- [What Gets Installed](#-what-gets-installed)
- [Usage](#-usage)
- [Customization](#-customization)
- [Maintenance](#-maintenance)
- [Troubleshooting](#-troubleshooting)
- [Tips & Tricks](#-tips--tricks)
- [Secrets & Sensitive Data](#-secrets--sensitive-data)
- [What This Does NOT Cover](#-what-this-does-not-cover)

---

## 󰑣 Quick Start

```bash
# On a fresh Arch install with base + networking:
sudo pacman -S ansible-core git
git clone https://github.com/jmeezy/ansible-system.git ~/ansible-system
cd ~/ansible-system
ansible-playbook -K playbook.yml
```

---

## 󰏖 Prerequisites

### Fresh Arch Install Requirements

Before running this playbook, ensure you have:

1. **Base Arch Linux installed** (via `archinstall` or manual)
2. **Working internet connection**
3. **A non-root user with sudo access**
4. **Base packages:**
   ```bash
   sudo pacman -S base-devel git ansible-core
   ```

### If Migrating from Existing System

1. **Backup your `/home` directory** (this playbook doesn't touch it)
2. **Export your SSH/GPG keys**
3. **Note any manual configurations** you've made

---

## 󰈙 Full Installation Guide

### Step 1: Fresh Arch Install

```bash
# Boot Arch ISO, connect to internet, then:
archinstall
# Select: Desktop → Hyprland (or minimal + add later)
# Create user with sudo privileges
# Reboot into new system
```

### Step 2: Initial Setup

```bash
# Login as your user, then:
sudo pacman -Syu
sudo pacman -S git ansible-core

# Clone this repo
git clone https://github.com/jmeezy/ansible-system.git ~/ansible-system
cd ~/ansible-system
```

### Step 3: Run the Playbook

```bash
# Full installation (will prompt for sudo password)
ansible-playbook -K playbook.yml

# Or run specific roles only:
ansible-playbook -K playbook.yml --tags packages      # Only packages
ansible-playbook -K playbook.yml --tags aur           # Only AUR
ansible-playbook -K playbook.yml --tags services      # Only services
ansible-playbook -K playbook.yml --tags dotfiles      # Only dotfiles
```

### Step 4: Post-Installation

```bash
# Reboot to apply all changes
sudo reboot

# After reboot, restore your data:
# - Copy /home backup
# - Import SSH keys: cp -r /backup/.ssh ~/
# - Import GPG keys: gpg --import /backup/private.key
# - Login to applications (browser, Discord, etc.)
```

---

## 󰏗 What Gets Installed

### 󰣇  Official Packages (140)

> **📋 Source of Truth:** The canonical package lists are in:
> - `roles/packages/tasks/packages.txt` (official)
> - `roles/aur/tasks/aur-packages.txt` (AUR)
>
> Run `./sync.sh` to update these from your current system.


| Category | Packages |
|----------|----------|
| **Desktop** | hyprland, waybar, mako, fuzzel, swww, hyprlock, hypridle |
| **Terminal** | kitty, zsh, starship, tmux, btop, fastfetch |
| **Development** | git, neovim, base-devel, clang, gdb, python-pip |
| **Gaming** | steam, lutris, gamemode, gamescope, mangohud, wine-staging |
| **Media** | mpd, ncmpcpp, ncspot, spotify-launcher |
| **Utilities** | thunar, file-roller, zathura, qalculate-gtk |
| **Fonts** | noto-fonts, ttf-jetbrains-mono-nerd, ttf-roboto |

### 󰞯  AUR Packages (42)

| Category | Packages |
|----------|----------|
| **Browsers** | librewolf-bin, brave-bin |
| **Gaming** | heroic-games-launcher, bottles, protonup-qt-bin, ryujinx |
| **Theming** | nordic-theme, arc-gtk-theme, nordzy-cursors, wallust |
| **Tools** | visual-studio-code-bin, paru, yay |
| **Fun** | cmatrix-git, cbonsai-git, pipes.sh |

### Enabled Services

- `NetworkManager` - Network management
- `bluetooth` - Bluetooth support
- `ufw` - Firewall
- `coolercontrold` - Fan/cooling control
- `cronie` - Scheduled tasks
- `reflector.timer` - Mirror list updates

### Dotfiles Included

- **Hyprland** - Full config with keybinds, rules, animations
- **Waybar** - Custom modules, scripts, styling
- **Kitty** - Terminal with Nord theme
- **Mako** - Notification daemon config
- **Fuzzel** - Application launcher
- **Starship** - Shell prompt
- **Zsh** - Shell config with oh-my-zsh

---

## 󰊗 Usage

### Running the Full Playbook

```bash
cd ~/ansible-system
ansible-playbook -K playbook.yml
```

### Running Specific Roles

```bash
# Only install official packages
ansible-playbook -K playbook.yml --tags packages

# Only install AUR packages
ansible-playbook -K playbook.yml --tags aur

# Only configure services
ansible-playbook -K playbook.yml --tags services

# Only symlink dotfiles
ansible-playbook -K playbook.yml --tags dotfiles
```

### Available Tags Reference

| Tag | What It Does |
|-----|--------------|
| `packages` | Install official repo packages (pacman) |
| `aur` | Install AUR packages (paru) |
| `services` | Enable system & user services |
| `dotfiles` | Apply configs via chezmoi (or fallback) |
| `chezmoi` | Alias for dotfiles tag |

**Combine tags:** `--tags "packages,aur"` to run multiple.
**Skip tags:** `--skip-tags aur` to exclude specific roles.

### Dry Run (Check Mode)

```bash
# See what would change without making changes
ansible-playbook -K playbook.yml --check
```

### Verbose Output

```bash
# More detailed output
ansible-playbook -K playbook.yml -v

# Even more verbose
ansible-playbook -K playbook.yml -vvv
```

---

## 󰒓 Customization

### Adding/Removing Packages

**Official packages:**
```bash
# Edit the package list
nvim roles/packages/tasks/packages.txt

# Add one package per line, e.g.:
firefox
vlc
```

**AUR packages:**
```bash
# Edit the AUR package list
nvim roles/aur/tasks/aur-packages.txt
```

### Adding Services

Edit `group_vars/all.yml`:
```yaml
system_services:
  - NetworkManager
  - bluetooth
  - ufw
  - your-new-service  # Add here
```

### Managing Dotfiles

1. Add your config to `files/dotfiles/`
2. Update the mapping in `group_vars/all.yml`:
   ```yaml
   dotfiles_map:
     - { src: "your-config", dest: ".config/your-config" }
   ```

### Changing AUR Helper

Edit `group_vars/all.yml`:
```yaml
aur_helper: yay  # or paru
```

---

## 󰑓 Maintenance

### Updating Package Lists from Current System

```bash
# Regenerate official packages list (excludes AUR)
pacman -Qqen > roles/packages/tasks/packages.txt

# Regenerate AUR packages list (excludes debug packages)
pacman -Qqem | grep -v "\-debug$" > roles/aur/tasks/aur-packages.txt

# Commit changes
git add -A && git commit -m "Update package lists $(date +%Y-%m-%d)"
git push
```

### Syncing Dotfiles

```bash
# Copy latest configs to repo
cp -r ~/.config/hypr files/dotfiles/
cp -r ~/.config/waybar files/dotfiles/
cp -r ~/.config/kitty files/dotfiles/
cp ~/.zshrc files/dotfiles/zshrc

# Commit
git add -A && git commit -m "Update dotfiles $(date +%Y-%m-%d)"
git push
```

### Full Sync Script

Create `~/ansible-system/sync.sh`:
```bash
#!/bin/bash
cd ~/ansible-system

# Update package lists
pacman -Qqen > roles/packages/tasks/packages.txt
pacman -Qqem | grep -v "\-debug$" > roles/aur/tasks/aur-packages.txt

# Update key dotfiles
cp -r ~/.config/hypr files/dotfiles/
cp -r ~/.config/waybar files/dotfiles/
cp -r ~/.config/kitty files/dotfiles/
cp -r ~/.config/mako files/dotfiles/
cp ~/.config/starship.toml files/dotfiles/
cp ~/.zshrc files/dotfiles/zshrc

# Commit and push
git add -A
git commit -m "Sync: $(date +%Y-%m-%d %H:%M)"
git push

echo "✅ Synced!"
```

---

## 󰔫 Troubleshooting

### AUR Package Fails to Install

```bash
# Try installing manually first
paru -S package-name

# If it works, the playbook should work next time
# If not, remove from aur-packages.txt
```

### Dotfiles Not Linking

```bash
# Check if source exists
ls -la files/dotfiles/

# Manual symlink
ln -sf ~/ansible-system/files/dotfiles/hypr ~/.config/hypr
```

### Ansible Not Found

```bash
sudo pacman -S ansible-core
# or for full ansible with more modules:
sudo pacman -S ansible
```

### Permission Denied Errors

```bash
# Make sure you're using -K flag
ansible-playbook -K playbook.yml

# Or run with become
ansible-playbook playbook.yml --become --ask-become-pass
```

### Package Conflicts

```bash
# Check what's conflicting
sudo pacman -Syu

# Remove conflicting package first if needed
sudo pacman -R conflicting-package
```

---

## 󰛨 Tips & Tricks

### 1. Keep This Repo Private
Your dotfiles may contain paths, usernames, or preferences you don't want public.

### 2. Use Branches for Experiments
```bash
git checkout -b test-new-setup
# Make changes, test
git checkout master  # Go back if it fails
```

### 3. Sync Before Major Updates
```bash
# Before updating system
./sync.sh
sudo pacman -Syu
```

### 4. Test on a VM First
Before running on your main machine, test in a VM:
```bash
# Create Arch VM, clone repo, run playbook
```

### 5. Recovery Checklist
If things go wrong:
1. Boot from Arch ISO
2. Mount your partition
3. Chroot in: `arch-chroot /mnt`
4. Fix or reinstall packages
5. Or restore from Timeshift

### 6. Useful Ansible Commands
```bash
# List all tasks
ansible-playbook playbook.yml --list-tasks

# Start from specific task
ansible-playbook playbook.yml --start-at-task="Install AUR packages"

# Skip specific tags
ansible-playbook playbook.yml --skip-tags aur
```

### 7. Speed Up AUR Installs
The playbook installs AUR packages one-by-one for reliability. For faster installs:
```bash
paru -S --needed $(cat roles/aur/tasks/aur-packages.txt | tr '\n' ' ')
```

### 8. Backup Before Running
```bash
sudo timeshift --create --comments "Before ansible run"
```

### 9. Preview Changes with --diff
See exactly what will change before applying:
```bash
# Show what would change
ansible-playbook -K playbook.yml --diff --check

# Apply and show changes
ansible-playbook -K playbook.yml --diff
```

---

## 󰌾 Secrets & Sensitive Data

This playbook **intentionally avoids secrets**. For future expansion:

### What's NOT Stored Here
- SSH keys (keep in encrypted backup or password manager)
- GPG keys (import manually: `gpg --import`)
- WiFi passwords (NetworkManager stores these)
- API keys / tokens (use environment variables)
- Browser logins (use browser sync)

### If You Need Secrets Later: Ansible Vault

```bash
# Create encrypted secrets file
ansible-vault create group_vars/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/vault.yml

# Run playbook with vault
ansible-playbook -K --ask-vault-pass playbook.yml

# Example vault.yml contents:
# ---
# secret_api_key: "your-key-here"
# wifi_password: "super-secret"
```

### Best Practices
1. **Never commit unencrypted secrets** to git
2. **Use `ansible-vault`** for any sensitive variables
3. **Keep vault password** in a password manager
4. **`.gitignore`** already covers `secrets.yml` and `*.vault`

---

## 󰅜 What This Does NOT Cover

| Not Covered | Why | Solution |
|-------------|-----|----------|
| `/home` data | Personal files, too large | Use rsync, Borg, or restic |
| Browser profiles | Logged-in sessions | Browser sync or manual backup |
| SSH/GPG keys | Security sensitive | Backup separately, encrypted |
| Game saves | Application state | Steam Cloud, manual backup |
| Database data | Runtime state | `pg_dump`, separate backup |
| Flatpak app data | Sandboxed storage | `~/.var/app/` backup |
| WiFi passwords | Stored in NetworkManager | `/etc/NetworkManager/system-connections/` |

### Recommended Backup Strategy

```
├── This Ansible repo     → System rebuild (git)
├── /home rsync backup    → Personal files (external drive)
├── SSH/GPG keys          → Encrypted backup (separate USB)
└── Package list          → Quick reference (in this repo)
```

---

## 󰉋 Repository Structure

```
ansible-system/
├── README.md              # This file
├── playbook.yml           # Main playbook entry point
├── inventory.yml          # Target hosts (localhost)
├── ansible.cfg            # Ansible configuration
├── group_vars/
│   └── all.yml            # Global variables
├── roles/
│   ├── packages/
│   │   └── tasks/
│   │       ├── main.yml         # Package installation logic
│   │       └── packages.txt     # Official package list
│   ├── aur/
│   │   └── tasks/
│   │       ├── main.yml         # AUR installation logic
│   │       └── aur-packages.txt # AUR package list
│   ├── services/
│   │   └── tasks/
│   │       └── main.yml         # Service enablement
│   └── dotfiles/
│       └── tasks/
│           └── main.yml         # Dotfile symlinking
└── files/
    └── dotfiles/          # Actual configuration files
        ├── hypr/          # Hyprland config
        ├── waybar/        # Waybar config + scripts
        ├── kitty/         # Terminal config
        ├── mako/          # Notifications
        ├── fuzzel/        # App launcher
        ├── btop/          # System monitor
        ├── fastfetch/     # System info
        ├── starship.toml  # Shell prompt
        └── zshrc          # Shell config
```

---

## 󰒋 Related Repository

This ansible repo works in tandem with my **chezmoi dotfiles**:

| Repository | Purpose |
|------------|---------|
| **[ansible-system](https://github.com/jmeezy/ansible-system)** (this repo) | System packages, services, full rebuild |
| **[dotfiles](https://github.com/jmeezy/dotfiles)** | User configs, themes, keybinds (via chezmoi) |

### How They Work Together

```
ansible-system                          dotfiles (chezmoi)
├── packages (pacman)                   ├── hypr/
├── aur (paru)                          ├── waybar/
├── services (systemd)                  ├── kitty/
└── dotfiles role ──────────────────────┴── Pulls & applies chezmoi repo
```

### Workflow

| Task | Command |
|------|---------|
| **Full system rebuild** | `ansible-playbook -K playbook.yml` |
| **Dotfiles only** | `chezmoi init --apply jmeezy` |
| **Edit a config** | Edit file → `chezmoi add <file>` → commit/push |
| **Sync everything** | `./sync.sh` (syncs both repos) |

---

## 󰃭 Generated

- **Date:** 2026-01-15
- **System:** Arch Linux + Hyprland
- **Packages:** 140 official + 42 AUR
- **Dotfiles:** 9 configs included

---

## 󰈙 License

MIT License - See [LICENSE](LICENSE) for details.


---

## 󱗗 Credits

- **Ansible** - Infrastructure automation
- **chezmoi** - Dotfile management
- **Arch Linux** - BTW, I use Arch
- **Hyprland** - Wayland compositor

---

<div align="center">

**"Automation is the art of teaching machines to be lazy for you."**

</div>

---

<sub>Original work by **jmeezy** • [github.com/jmeezy](https://github.com/jmeezy) • 2026</sub>

<!-- ZHIuYmFrbGF2YQ== -->
