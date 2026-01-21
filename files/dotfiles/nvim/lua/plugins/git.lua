-- Git integration and file icons
return {
  -- Gitsigns for git integration
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")

        -- Actions
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- File icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    opts = {
      -- Nord theme colors for file icons
      color_icons = true,
      default = true,
      override = {
        zsh = {
          icon = "",
          color = "#A3BE8C", -- Nord green
          name = "Zsh"
        },
        vim = {
          icon = "",
          color = "#81A1C1", -- Nord blue
          name = "Vim"
        },
        lua = {
          icon = "",
          color = "#88C0D0", -- Nord light blue
          name = "Lua"
        },
        js = {
          icon = "",
          color = "#EBCB8B", -- Nord yellow
          name = "JavaScript"
        },
        ts = {
          icon = "",
          color = "#88C0D0", -- Nord light blue
          name = "TypeScript"
        },
        json = {
          icon = "",
          color = "#EBCB8B", -- Nord yellow
          name = "Json"
        },
        md = {
          icon = "",
          color = "#D8DEE9", -- Nord light gray
          name = "Markdown"
        },
        py = {
          icon = "",
          color = "#EBCB8B", -- Nord yellow
          name = "Python"
        },
        css = {
          icon = "",
          color = "#88C0D0", -- Nord light blue
          name = "CSS"
        },
        html = {
          icon = "",
          color = "#D08770", -- Nord orange
          name = "HTML"
        },
      },
    },
  },

  -- Schema store for JSON/YAML
  {
    "b0o/schemastore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
}