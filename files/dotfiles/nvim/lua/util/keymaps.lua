-- LSP Keymaps
local M = {}

function M.on_attach(client, buffer)
  local function map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.buffer = buffer
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- LSP actions
  map("n", "gd", vim.lsp.buf.definition, { desc = "Goto Definition" })
  map("n", "gr", vim.lsp.buf.references, { desc = "References" })
  map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
  map("n", "gI", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
  map("n", "gy", vim.lsp.buf.type_definition, { desc = "Goto Type Definition" })
  map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
  map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
  map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
  map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
  map("v", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
  map("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run Codelens" })
  map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh & Display Codelens" })
  map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

  -- Diagnostics
  map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
  map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
  map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
  map("n", "]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, { desc = "Next Error" })
  map("n", "[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, { desc = "Prev Error" })
  map("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
  end, { desc = "Next Warning" })
  map("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
  end, { desc = "Prev Warning" })

  -- Format
  map({ "n", "v" }, "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
  end, { desc = "Format" })
end

return M