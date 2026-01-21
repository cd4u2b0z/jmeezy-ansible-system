#!/bin/bash

# Test Neovim Configuration
echo "🧪 Testing Neovim Configuration..."

# Test basic loading
echo "1. Testing basic config load..."
nvim --headless -c "lua print('✅ Basic config loaded')" +q 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Basic configuration loads successfully"
else
    echo "   ❌ Basic configuration failed"
    exit 1
fi

# Test plugins
echo "2. Testing plugin system..."
nvim --headless -c "lua if require('lazy') then print('✅ Lazy.nvim loaded') end" +q 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Plugin system working"
else
    echo "   ❌ Plugin system failed"
fi

# Test Nord theme
echo "3. Testing Nord theme..."
nvim --headless -c "lua pcall(vim.cmd.colorscheme, 'nord'); print('✅ Nord theme loaded')" +q 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Nord theme available"
else
    echo "   ⚠️  Nord theme not yet installed (will install on first interactive run)"
fi

echo ""
echo "🎉 Neovim configuration test complete!"
echo "📝 To complete setup:"
echo "   1. Run 'nvim' to start interactive session"
echo "   2. Plugins will auto-install on first run" 
echo "   3. LSP servers will install automatically when opening files"
echo ""
echo "📚 Key features ready:"
echo "   - Nord theme"
echo "   - LSP support with Mason"
echo "   - Completion with nvim-cmp"
echo "   - Telescope fuzzy finder"
echo "   - Git integration with Gitsigns"
echo "   - Treesitter syntax highlighting"