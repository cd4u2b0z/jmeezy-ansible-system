#!/bin/bash

echo "🔍 Checking LSP Server Installation Status..."

# Check installations via Mason
nvim --headless -c "
lua << EOF
local registry = require('mason-registry')
local servers = {
  'lua-language-server',
  'bash-language-server', 
  'json-lsp',
  'yaml-language-server',
  'marksman'
}

print('📦 LSP Server Installation Status:')
print('═════════════════════════════════════')

for _, server in ipairs(servers) do
  if registry.is_installed(server) then
    print('✅ ' .. server .. ' - INSTALLED')
  else
    print('❌ ' .. server .. ' - NOT INSTALLED')
  end
end

print('═════════════════════════════════════')
print('📝 To manually install missing servers:')
print('   1. Run: nvim')
print('   2. Type: :Mason')
print('   3. Navigate and press \"i\" to install')
EOF
" -c "q"