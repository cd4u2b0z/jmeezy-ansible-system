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

## 🔧 Troubleshooting

### ❌ "Fatal: destination path already exists and is not an empty directory"

You already have a folder at that location. Remove it first:

```bash
rm -rf ~/ansible-system
git clone https://github.com/cd4u2b0z/jmeezy-ansible-system.git ~/ansible-system
```

Or clone to a different folder:

```bash
git clone https://github.com/cd4u2b0z/jmeezy-ansible-system.git ~/jmeezy-ansible-system
cd ~/jmeezy-ansible-system
```

---

### ❌ "No module named 'ansible_collections.community'" or "couldn't resolve module/action 'community.general.pacman'"

You forgot to install the Ansible collection. Run:

```bash
ansible-galaxy collection install -r requirements.yml
```

Or manually:

```bash
ansible-galaxy collection install community.general
```

---

### ❌ "BECOME password" prompt - what do I enter?

Enter your **sudo password** - the same password you use to log into your system or when running `sudo` commands.

To test if you know your sudo password:

```bash
sudo whoami
```

Whatever password works there is the one you use for Ansible.

---

### ❌ NVIDIA driver conflicts ("lib32-nvidia-utils and lib32-nvidia-580xx-utils are in conflict")

CachyOS ships with its own NVIDIA driver packages that conflict with standard Arch packages. Remove the CachyOS versions first:

```bash
sudo pacman -Rdd nvidia-580xx-utils lib32-nvidia-580xx-utils
```

Then re-run the playbook:

```bash
ansible-playbook playbook.yml --ask-become-pass
```

---

### ❌ "Failed to install package(s)" with package provider choices

When pacman asks you to choose between multiple providers (like choosing between `cachyos-extra-v3` and `extra` repos), this can cause the automated install to fail.

**Solution**: Just press Enter to accept defaults when running manually, or the playbook handles this with `--noconfirm`.

If it still fails, try installing the problematic packages manually first:

```bash
sudo pacman -S <package-name>
```

Then re-run the playbook.

---

### ❌ Hyprland not starting or display issues

1. Make sure NVIDIA drivers are properly installed:
   ```bash
   nvidia-smi
   ```

2. Check that the monitor config matches your setup. Edit `~/.config/hypr/hyprland.conf`:
   ```bash
   # Should be set for 1080p:
   monitor = ,1920x1080@60,auto,1
   ```

3. Ensure environment variables are set (in hyprland.conf):
   ```
   env = WLR_NO_HARDWARE_CURSORS,1
   env = LIBVA_DRIVER_NAME,nvidia
   env = __GLX_VENDOR_LIBRARY_NAME,nvidia
   ```

---

### ❌ No sound / PipeWire issues

```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber

# Check status
systemctl --user status pipewire
```

---

### ❌ AUR packages failing

Some AUR packages may need manual intervention. If the AUR role fails:

1. Install `yay` or `paru` manually:
   ```bash
   sudo pacman -S --needed git base-devel
   git clone https://aur.archlinux.org/yay.git
   cd yay && makepkg -si
   ```

2. Then install AUR packages manually:
   ```bash
   yay -S <package-name>
   ```

---

## 🔄 Re-running the Playbook

It's safe to re-run the playbook multiple times. Ansible is idempotent - it will skip tasks that are already completed:

```bash
cd ~/ansible-system
ansible-playbook playbook.yml --ask-become-pass
```

---

## 📝 Credits

Based on [cd4u2b0z/ansible-system](https://github.com/cd4u2b0z/ansible-system), customized for jmeezy's hardware.
