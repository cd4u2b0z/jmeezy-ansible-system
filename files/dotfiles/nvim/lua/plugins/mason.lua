-- Mason for LSP server management
return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ui = {
        -- Nord theme colors for Mason UI
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- Mason LSPConfig integration  
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig", 
    },
    opts = {
      -- Don't specify servers to avoid name conflicts
      ensure_installed = {},
      automatic_installation = false, -- Completely disable automatic installation
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },
}