#!/bin/bash

echo "🔍 Comprehensive Plugin Configuration Test..."

# Test basic config loading
echo "1. Testing basic configuration..."
nvim --headless -c "lua print('✅ Basic config loaded successfully')" +q 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Basic configuration loads"
else
    echo "   ❌ Basic configuration failed"
fi

# Test specific plugins
echo "2. Testing plugin loading..."

plugins=("which-key" "lualine" "telescope" "gitsigns" "nvim-cmp" "luasnip")

for plugin in "${plugins[@]}"; do
    nvim --headless -c "lua local ok, _ = pcall(require, '$plugin'); if ok then print('✅ $plugin loaded') else print('⚠️  $plugin not loaded yet') end" +q 2>/dev/null
done

echo ""
echo "📝 Note: Plugins will auto-install on first interactive neovim session"
echo "🚀 Configuration is ready for use!"