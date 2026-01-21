# 🎮 Jmeezy's CachyOS + Hyprland System Configuration

Ansible playbook to set up CachyOS + Hyprland system, customized for jmeezy's hardware.

![CachyOS](https://img.shields.io/badge/CachyOS-1793D1?style=flat&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=flat&logo=wayland&logoColor=black)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=flat&logo=ansible&logoColor=white)

---

## 🖥️ Hardware Specs

| Component | Spec |
|-----------|------|
| **Motherboard** | ASRock Z97 Extreme 3 |
| **CPU** | Intel i7 4790 |
| **GPU** | NVIDIA GeForce GTX 970 |
| **RAM** | 16GB DDR3 |
| **Resolution** | 1920x1080 (1080p) |

---

## 🚀 Quick Start

```bash
# 1. Install prerequisites
sudo pacman -S ansible-core git

# 2. Clone this repo
git clone https://github.com/cd4u2b0z/jmeezy-ansible-system.git ~/ansible-system
cd ~/ansible-system

# 3. Install Ansible collections
ansible-galaxy collection install -r requirements.yml

# 4. Run the playbook
ansible-playbook playbook.yml --ask-become-pass
```

When prompted for "BECOME password", enter your **sudo password** (your user login password).

---

## 📦 What Gets Installed

- **Window Manager**: Hyprland (Wayland compositor)
- **Terminal**: Kitty
- **Shell**: Zsh with starship prompt
- **Editor**: Neovim
- **File Manager**: Thunar
- **App Launcher**: Fuzzel
- **Status Bar**: Waybar
- **Notifications**: Mako
- **Audio**: PipeWire + PulseAudio compatibility
- **Gaming**: Steam, Lutris, MangoHud, GameMode, Wine
- **GPU Drivers**: NVIDIA proprietary (for GTX 970)

---

## 🎨 Dotfiles

This playbook works best with the matching dotfiles repo:

```bash
# Install chezmoi and apply dotfiles
sudo pacman -S chezmoi
chezmoi init --apply https://github.com/cd4u2b0z/jmeezy-chezmoi.git
```

---

## ⚠️ CachyOS Notes

CachyOS may have some packages pre-installed or use different package names. If you encounter conflicts:

1. **NVIDIA driver conflicts**: CachyOS uses its own nvidia packages. If you get conflicts, run:
   ```bash
   sudo pacman -Rdd nvidia-580xx-utils lib32-nvidia-580xx-utils
   ```
   Then re-run the playbook.

2. **Package provider choices**: When pacman asks to choose a provider, just press Enter for defaults.

---

## 📝 Credits

Based on [cd4u2b0z/ansible-system](https://github.com/cd4u2b0z/ansible-system), customized for jmeezy's hardware.
