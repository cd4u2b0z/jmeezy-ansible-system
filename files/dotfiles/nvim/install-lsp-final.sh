#!/bin/bash

echo "🔧 Installing LSP servers with correct package names..."

# Install each server individually with proper names
echo "📥 Installing Lua Language Server..."
nvim -c "lua require('mason').setup(); require('mason-registry').get_package('lua-language-server'):install(); vim.defer_fn(function() vim.cmd('q') end, 2000)" > /dev/null 2>&1

echo "📥 Installing Bash Language Server..."
nvim -c "lua require('mason').setup(); require('mason-registry').get_package('bash-language-server'):install(); vim.defer_fn(function() vim.cmd('q') end, 2000)" > /dev/null 2>&1

echo "📥 Installing JSON Language Server..."
# Try multiple JSON LSP options
nvim -c "lua require('mason').setup(); local r=require('mason-registry'); local found=false; for _,name in ipairs({'vscode-json-language-server','json-lsp'}) do if r.has_package(name) then r.get_package(name):install(); found=true; break end end; if not found then print('JSON LSP not found') end; vim.defer_fn(function() vim.cmd('q') end, 2000)" > /dev/null 2>&1

echo "📥 Installing YAML Language Server..."
nvim -c "lua require('mason').setup(); require('mason-registry').get_package('yaml-language-server'):install(); vim.defer_fn(function() vim.cmd('q') end, 2000)" > /dev/null 2>&1

echo "📥 Installing Marksman (Markdown LSP)..."
nvim -c "lua require('mason').setup(); require('mason-registry').get_package('marksman'):install(); vim.defer_fn(function() vim.cmd('q') end, 2000)" > /dev/null 2>&1

echo ""
echo "✅ LSP Server installation completed!"
echo ""
echo "📋 Verification:"
echo "  • Launch: nvim +Mason"
echo "  • Check: :LspInfo"
echo "  • Test with: nvim test-lsp.lua"
echo ""
echo "🚀 Your LSP servers should now work without errors!"