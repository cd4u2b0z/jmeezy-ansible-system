-- Utility functions
local M = {}

M.root_patterns = { ".git", "lua" }

-- Check if a plugin is available
function M.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

-- Get project root
function M.get_root()
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  local root = path and vim.fs.dirname(path) or vim.loop.cwd()
  local found = vim.fs.find(M.root_patterns, { path = root, upward = true })[1]
  return found and vim.fs.dirname(found) or root
end

return M