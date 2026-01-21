#!/bin/bash

# Mason Tools Installer for Neovim
# This script will install LSP servers and tools after Neovim is properly set up

echo "🔧 Installing Mason tools for Neovim..."

# Start neovim and install mason tools
nvim --headless -c "
lua << EOF
-- Wait for Mason to load
vim.defer_fn(function()
  local mason_registry = require('mason-registry')
  local packages = {
    'lua-language-server',
    'bash-language-server', 
    'json-lsp',
    'yaml-language-server',
    'marksman',
    'stylua',
    'shfmt',
    'prettier'
  }
  
  for _, package_name in ipairs(packages) do
    local package = mason_registry.get_package(package_name)
    if not package:is_installed() then
      print('Installing: ' .. package_name)
      package:install()
    else
      print('Already installed: ' .. package_name)
    end
  end
  
  -- Wait a bit then quit
  vim.defer_fn(function()
    vim.cmd('qall!')
  end, 5000)
end, 2000)
EOF
" +qall!

echo "✅ Mason tools installation initiated!"
echo "📝 LSP servers will install in the background on first use."