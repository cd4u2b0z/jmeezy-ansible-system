# LSP Server Installation Guide

## Manual Installation via Mason

If you encounter installation issues with mason-lspconfig, you can manually install LSP servers:

### Option 1: Interactive Mason UI
```bash
# Launch Neovim
nvim

# Open Mason UI
:Mason

# Install servers manually:
# - Type '2' to filter by LSP servers
# - Navigate to desired server and press 'i' to install
```

### Option 2: Command Line Installation
```bash
# In Neovim command mode:
:MasonInstall lua-language-server
:MasonInstall bash-language-server  
:MasonInstall json-lsp
:MasonInstall yaml-language-server
:MasonInstall marksman
```

### Option 3: Use the install script
```bash
# Run our custom installer
~/.config/nvim/install-lsp-servers.sh
```

## LSP Server Mappings

| Language | Mason Package | LSP Config Name |
|----------|---------------|-----------------|
| Lua | `lua-language-server` | `lua_ls` |
| Bash | `bash-language-server` | `bashls` |
| JSON | `json-lsp` | `jsonls` |
| YAML | `yaml-language-server` | `yamlls` |
| Markdown | `marksman` | `marksman` |

## Verification

After installation, LSP should work automatically when you open relevant files:
- `.lua` files → lua_ls
- `.sh`, `.bash` files → bashls  
- `.json` files → jsonls
- `.yml`, `.yaml` files → yamlls
- `.md` files → marksman

## Troubleshooting

If LSP servers don't start:
1. Check installation: `:Mason`
2. Check LSP status: `:LspInfo` 
3. Check logs: `:MasonLog`