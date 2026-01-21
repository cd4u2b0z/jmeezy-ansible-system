# Changelog

All notable changes to ansible-system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-16

### Added
- **Dr. Baklava watermarks** - Hidden and visible attribution
- **Credits section** - Acknowledgments for Ansible, chezmoi, Arch, Hyprland
- **Inspirational quote** - "Automation is the art of teaching machines to be lazy for you."
- **Tags reference table** - Documentation for all Ansible tags
- **CI improvements** - Dry-run validation, ansible-lint integration

### Changed
- Reverted to Nerd Font icons (more reliable than emojis)
- Updated TOC anchor format for better compatibility
- Improved error handling in roles
- Skip var-naming lint rule (personal repo style)

### Fixed
- TOC anchors now work correctly with icons
- CI pipeline uses pip install for ansible-lint
- Various typos and documentation issues

## [1.1.0] - 2026-01-15

### Added
- **chezmoi integration** - Primary dotfile manager with Ansible fallback
- **Cross-reference** - Links to chezmoi dotfiles repository
- **Package source of truth** - Clear documentation of package management
- **User systemd units** - Automatic enablement after dotfiles deployment

### Changed
- Architecture: chezmoi is now primary, Ansible handles provisioning + fallback
- Clean separation of concerns between repos
- Improved documentation structure

## [1.0.0] - 2026-01-15

### Added
- **Initial release** - Complete Arch Linux + Hyprland system configuration
- **Core roles**
  - `packages` - Official and AUR package management
  - `dotfiles` - Configuration deployment via chezmoi
  - `services` - Systemd service enablement
  - `system` - System-level configuration
- **Comprehensive README** - Full documentation with usage examples
- **sync.sh script** - One-command sync for both repos
- **Nerd Font glyphs** - Beautiful terminal icons throughout
- **Tag-based execution** - Run specific parts with `--tags`

### Infrastructure
- 140+ official packages
- 42+ AUR packages
- 9 managed dotfile configs
- GitHub Actions CI/CD

---

## Tags Reference

| Tag | Description |
|-----|-------------|
| `packages` | Install all packages |
| `aur` | AUR packages only |
| `dotfiles` | Deploy dotfiles via chezmoi |
| `services` | Enable systemd services |
| `system` | System configuration |

---

<sub>Original work by **Dr. Baklava** • [github.com/cd4u2b0z](https://github.com/cd4u2b0z) • 2026</sub>
