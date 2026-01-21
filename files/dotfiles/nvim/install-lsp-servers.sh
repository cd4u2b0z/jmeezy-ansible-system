#!/bin/bash

echo "🔧 Manual LSP Server Installation via Mason"

# Run nvim to manually install LSP servers
nvim --headless -c "
lua << EOF
-- Wait for Mason to initialize
vim.defer_fn(function()
  local mason = require('mason')
  local registry = require('mason-registry')
  
  local servers = {
    'lua-language-server',
    'bash-language-server', 
    'json-lsp',
    'yaml-language-server',
    'marksman'
  }
  
  print('📦 Installing LSP servers...')
  
  for _, server in ipairs(servers) do
    if registry.is_installed(server) then
      print('✅ ' .. server .. ' already installed')
    else
      print('📥 Installing ' .. server)
      local pkg = registry.get_package(server)
      pkg:install():once('closed', function()
        if pkg:is_installed() then
          print('✅ ' .. server .. ' installed successfully')
        else
          print('❌ Failed to install ' .. server)
        end
      end)
    end
  end
  
  -- Exit after a delay
  vim.defer_fn(function()
    print('🎉 Installation process complete!')
    vim.cmd('qall!')
  end, 10000)
end, 2000)
EOF
"

echo "✅ LSP server installation initiated!"
echo "📝 Servers will install in the background."