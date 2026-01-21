-- Test Lua file for LSP functionality
local M = {}

function M.greet(name)
  print("Hello, " .. name .. "!")
end

function M.add(a, b)
  return a + b
end

return M