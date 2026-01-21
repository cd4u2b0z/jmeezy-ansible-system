#!/bin/bash

echo "🎉 LSP Server Installation Complete!"
echo "════════════════════════════════════════"

echo ""
echo "📦 Installed LSP Servers:"
echo "  ✅ lua-language-server   → .lua files"
echo "  ✅ bash-language-server  → .sh/.bash files"  
echo "  ✅ json-lsp             → .json files"
echo "  ✅ yaml-language-server  → .yml/.yaml files"
echo "  ✅ marksman             → .md files"

echo ""
echo "🧪 Test Files Created:"
echo "  📄 test-lsp.lua  → Test Lua LSP"
echo "  📄 test-lsp.sh   → Test Bash LSP" 
echo "  📄 test-lsp.json → Test JSON LSP"

echo ""
echo "🚀 How to Test:"
echo "  1. Run: nvim test-lsp.lua"
echo "  2. LSP should start automatically"
echo "  3. Try these features:"
echo "     • gd       → Go to definition"
echo "     • gr       → Find references"  
echo "     • K        → Show documentation"
echo "     • <leader>ca → Code actions"
echo "     • <leader>rn → Rename symbol"

echo ""
echo "📋 Verify Installation:"
echo "  • Run: nvim +Mason"
echo "  • Check: :LspInfo (in nvim)"
echo "  • Logs: :MasonLog (in nvim)"

echo ""
echo "✨ Your Nord-themed Neovim with LSP is ready!"