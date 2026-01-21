# Neovim Configuration - Nord Theme

Migrated from Linux Mint to Arch Linux with Nord theme instead of Gruvbox.

## ✅ Status: WORKING (No Installation Errors)

Configuration loads successfully without mason-lspconfig errors:
- Nord theme with arctic color palette  
- **Modern LSP support** with new `vim.lsp.config` API (Neovim 0.11+)
- **Updated Which-Key** with modern API (no health check issues)
- **Fixed Mason-LSPConfig** - no automatic installation conflicts
- Manual LSP server installation available
- Completion system with nvim-cmp
- Fuzzy finding with Telescope
- Git integration with Gitsigns
- Syntax highlighting with Treesitter

**No configuration errors** - Ready to use!

## Manual LSP Installation

Since automatic installation conflicts have been disabled, install LSP servers manually:

```bash
# Open Neovim and use Mason UI
nvim
:Mason

# Or install via commands:
:MasonInstall lua-language-server
:MasonInstall bash-language-server
:MasonInstall vscode-json-language-server
:MasonInstall yaml-language-server
:MasonInstall marksman
```

## Quick Start

```bash
# Launch Neovim
nvim

# First run will automatically:
# 1. Install all plugins via Lazy.nvim
# 2. Install LSP servers via Mason
# 3. Load Nord theme
```

## Features

### 🎨 Theme & UI
- **Nord colorscheme** - Clean arctic color palette
- **Lualine** - Beautiful statusline with Nord colors
- **Nvim-web-devicons** - File type icons with Nord color scheme

### 📝 Editing Experience
- **Nvim-autopairs** - Auto-close brackets and quotes
- **Mini.nvim** - Comment, move, surround, and pairs functionality
- **Which-key** - Keybinding hints and help
- **Render-markdown** - Preview markdown files inline
- **Twilight** - Dim inactive code regions
- **URLView** - Extract and browse URLs from buffers

### 🔍 Navigation & Search
- **Telescope** - Fuzzy finder with FZF native support
- **Treesitter** - Advanced syntax highlighting and text objects

### 🧩 Language Support & Completion
- **LSP** - Language server protocol support
- **Mason** - LSP server installer and manager
- **Nvim-cmp** - Completion engine with multiple sources:
  - LSP completions
  - Buffer completions
  - Path completions
  - Command line completions
- **LuaSnip** - Snippet engine
- **Friendly-snippets** - Pre-built snippet collection

### 🔧 Git Integration
- **Gitsigns** - Git hunks, blame, and status in the gutter

## Key Bindings

- `<Space>` - Leader key
- `<leader>ff` - Find files
- `<leader>fg` - Live grep
- `<leader>fb` - Switch buffers
- `<leader>ca` - Code actions
- `<leader>cr` - Rename symbol
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation

## Installation

1. Ensure you have Neovim installed:
   ```bash
   sudo pacman -S neovim
   ```

2. The configuration is already set up in `~/.config/nvim/`

3. First launch will automatically install all plugins via Lazy.nvim

4. LSP servers and tools will be installed via Mason

## File Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry
├── lua/
│   ├── config/
│   │   ├── options.lua         # Neovim options
│   │   ├── keymaps.lua         # Key mappings
│   │   ├── autocmds.lua        # Auto commands
│   │   └── icons.lua           # Icon definitions
│   ├── plugins/
│   │   ├── colorscheme.lua     # Nord theme
│   │   ├── lualine.lua         # Statusline
│   │   ├── telescope.lua       # Fuzzy finder
│   │   ├── treesitter.lua      # Syntax highlighting
│   │   ├── lsp.lua             # LSP configuration
│   │   ├── cmp.lua             # Completion
│   │   ├── luasnip.lua         # Snippets
│   │   ├── editor.lua          # Editing enhancements
│   │   ├── git.lua             # Git integration
│   │   └── mason.lua           # LSP manager
│   └── util/
│       ├── init.lua            # Utility functions
│       └── keymaps.lua         # LSP keymaps
```

## Theme Colors (Nord)

- **Background**: #2E3440 (Polar Night)
- **Foreground**: #D8DEE9 (Snow Storm)
- **Blue**: #5E81AC, #81A1C1, #88C0D0
- **Green**: #A3BE8C
- **Yellow**: #EBCB8B
- **Orange**: #D08770
- **Red**: #BF616A
- **Purple**: #B48EAD

Enjoy your new Nord-themed Neovim setup on Arch Linux! 🎉