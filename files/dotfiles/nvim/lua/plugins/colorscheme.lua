-- Dynamic Colorscheme - Wallust powered with Nord fallback
-- Reads colors from wallust-colors.lua, falls back to Nord if not available

return {
  {
    -- mini.base16 for applying wallust colors
    "echasnovski/mini.base16",
    lazy = false,
    priority = 1000,
    config = function()
      local ok, colors = pcall(require, "wallust-colors")
      if ok and colors and colors.colors then
        local c = colors.colors
        
        require("mini.base16").setup({
          palette = {
            base00 = c.background,  -- Default Background
            base01 = c.color0,      -- Lighter Background
            base02 = c.color8,      -- Selection Background
            base03 = c.color8,      -- Comments
            base04 = c.color7,      -- Dark Foreground
            base05 = c.foreground,  -- Default Foreground
            base06 = c.color15,     -- Light Foreground
            base07 = c.color15,     -- Light Background
            base08 = c.color1,      -- Variables, Errors
            base09 = c.color3,      -- Integers, Constants
            base0A = c.color3,      -- Classes, Search
            base0B = c.color2,      -- Strings
            base0C = c.color6,      -- Support, Regex
            base0D = c.color4,      -- Functions, Methods
            base0E = c.color5,      -- Keywords
            base0F = c.color1,      -- Deprecated
          },
          use_cterm = true,
        })
        
        -- FORCE solid background on line numbers (no frosted glass)
        vim.api.nvim_set_hl(0, "LineNr", { fg = c.color8, bg = c.background })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.color4, bg = c.background, bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = c.background })
        vim.api.nvim_set_hl(0, "FoldColumn", { fg = c.color8, bg = c.background })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = c.background, bg = c.background })
        
        -- Set terminal colors
        vim.g.terminal_color_0 = c.color0
        vim.g.terminal_color_1 = c.color1
        vim.g.terminal_color_2 = c.color2
        vim.g.terminal_color_3 = c.color3
        vim.g.terminal_color_4 = c.color4
        vim.g.terminal_color_5 = c.color5
        vim.g.terminal_color_6 = c.color6
        vim.g.terminal_color_7 = c.color7
        vim.g.terminal_color_8 = c.color8
        vim.g.terminal_color_9 = c.color9
        vim.g.terminal_color_10 = c.color10
        vim.g.terminal_color_11 = c.color11
        vim.g.terminal_color_12 = c.color12
        vim.g.terminal_color_13 = c.color13
        vim.g.terminal_color_14 = c.color14
        vim.g.terminal_color_15 = c.color15
      else
        -- Fallback: wallust-colors.lua not found, defer to Nord
        vim.g._use_nord_fallback = true
      end
    end,
  },
  {
    -- Nord as fallback when wallust colors unavailable
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 999,
    config = function()
      if vim.g._use_nord_fallback then
        vim.g.nord_contrast = true
        vim.g.nord_borders = false
        vim.g.nord_disable_background = false
        vim.g.nord_italic = true
        vim.g.nord_bold = true
        require('nord').set()
        -- Force solid background for Nord too
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#4C566A", bg = "#2E3440" })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#81A1C1", bg = "#2E3440", bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "#2E3440" })
        vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#4C566A", bg = "#2E3440" })
      end
    end,
  },
}
