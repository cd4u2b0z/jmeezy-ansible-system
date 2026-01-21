# 🪟 Hyprland Window Transparency Controls

## 🎮 Keybindings (Linux Mint Style)

### Basic Controls
- **Ctrl + -** : Decrease opacity by 10%
- **Ctrl + =** : Increase opacity by 10%  
- **Ctrl + +** : Increase opacity by 10% (alternative)

### Advanced Controls
- **Ctrl + Shift + -** : Big decrease (20% opacity change)
- **Ctrl + Shift + =** : Big increase (20% opacity change)

### Quick Presets
- **Super + O** : Reset to fully opaque (100%)
- **Super + Alt + H** : Set to half transparent (50%)

### Status & Info
- **Super + Shift + O** : Show current transparency status

## 🛠️ Manual Usage
You can also run the script manually from terminal:

```bash
~/.config/hypr/scripts/enhanced-transparency-control.sh decrease
~/.config/hypr/scripts/enhanced-transparency-control.sh increase
~/.config/hypr/scripts/enhanced-transparency-control.sh reset
~/.config/hypr/scripts/enhanced-transparency-control.sh half
~/.config/hypr/scripts/enhanced-transparency-control.sh quarter
~/.config/hypr/scripts/enhanced-transparency-control.sh status
```

## ✨ Features
- **Visual Progress Bar**: Shows transparency level as `[████░░░░░░] 40%`
- **Smart Notifications**: Different icons based on transparency level
- **Bounds Checking**: Prevents going below 10% or above 100%
- **Window Context**: Shows which window is being modified
- **Incremental Changes**: Smooth 10% or 20% steps

## 🎯 Use Cases
- **Terminal over Browser**: Make terminal 70-80% opaque to read through
- **Video Watching**: Set browser to 30% to see desktop/terminal behind
- **Multitasking**: Quick transparency for layered window workflow
- **Screenshots**: Temporarily make windows transparent for better shots

## 🔧 Customization
Edit `~/.config/hypr/scripts/enhanced-transparency-control.sh` to:
- Change step size (currently 0.1 = 10%)
- Modify notification duration (currently 1500ms)
- Add custom preset opacity levels
- Change progress bar appearance