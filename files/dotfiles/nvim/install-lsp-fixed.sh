#!/bin/bash

echo "🔧 Installing LSP servers via Mason..."

# Create a simple lua script for installation
cat > /tmp/install_lsp.lua << 'EOF'
-- Install LSP servers via Mason
local mason = require('mason')
local registry = require('mason-registry')

local servers = {
  'lua-language-server',
  'bash-language-server', 
  'json-lsp',
  'yaml-language-server',
  'marksman'
}

print('📦 Starting LSP server installation...')

for _, server in ipairs(servers) do
  if registry.is_installed(server) then
    print('✅ ' .. server .. ' already installed')
  else
    print('📥 Installing ' .. server .. '...')
    local pkg = registry.get_package(server)
    pkg:install()
  end
end

print('🎉 Installation process initiated!')
print('Check :Mason to see installation progress')
EOF

# Run the installation
nvim --headless -l /tmp/install_lsp.lua

# Clean up
rm -f /tmp/install_lsp.lua

echo "✅ LSP server installation completed!"
echo "📝 You can check the installation status with: nvim +Mason"