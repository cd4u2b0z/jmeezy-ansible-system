-- Lualine Statusline with Wallust dynamic theme
return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      vim.o.statusline = " "
    else
      vim.o.laststatus = 0
    end
  end,
  opts = function()
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    -- Try to load wallust colors, fallback to Nord-like defaults
    local ok, wallust = pcall(require, "wallust-colors")
    local c = ok and wallust.colors or {
      background = "#2E3440",
      foreground = "#D8DEE9",
      color0 = "#3B4252",
      color1 = "#BF616A",
      color2 = "#A3BE8C",
      color3 = "#EBCB8B",
      color4 = "#81A1C1",
      color5 = "#B48EAD",
      color6 = "#88C0D0",
      color7 = "#E5E9F0",
      color8 = "#4C566A",
    }

    -- Build custom theme from wallust colors
    local custom_theme = {
      normal = {
        a = { fg = c.background, bg = c.color4, gui = "bold" },
        b = { fg = c.foreground, bg = c.color8 },
        c = { fg = c.foreground, bg = c.background },
      },
      insert = {
        a = { fg = c.background, bg = c.color2, gui = "bold" },
      },
      visual = {
        a = { fg = c.background, bg = c.color5, gui = "bold" },
      },
      replace = {
        a = { fg = c.background, bg = c.color1, gui = "bold" },
      },
      command = {
        a = { fg = c.background, bg = c.color3, gui = "bold" },
      },
      inactive = {
        a = { fg = c.color8, bg = c.background },
        b = { fg = c.color8, bg = c.background },
        c = { fg = c.color8, bg = c.background },
      },
    }

    return {
      options = {
        theme = custom_theme,
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
          {
            function() return require("noice").api.status.command.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
            color = { fg = c.color4 },
          },
          {
            function() return require("noice").api.status.mode.get() end,
            cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
            color = { fg = c.color1 },
          },
          {
            function() return "  " .. require("dap").status() end,
            cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
            color = { fg = c.color3 },
          },
          { "encoding" },
          { "fileformat" },
        },
        lualine_y = {
          { "progress", separator = " ", padding = { left = 1, right = 0 } },
          { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
          function()
            return " " .. os.date("%R")
          end,
        },
      },
      extensions = { "neo-tree", "lazy" },
    }
  end,
}
