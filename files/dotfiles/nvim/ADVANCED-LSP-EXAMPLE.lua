-- ADVANCED LSP CONFIGURATION (What we started with)
-- This was the complex, feature-rich version before we simplified

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" }, -- More events
  dependencies = {
    "mason.nvim", -- Dynamic dependency resolution
    "williamboman/mason-lspconfig.nvim",
    {
      "hrsh7th/cmp-nvim-lsp",
      cond = function()
        return require("util").has("nvim-cmp") -- Conditional loading
      end,
    },
  },
  ---@class PluginLspOpts
  opts = {
    -- Advanced diagnostic configuration
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
      },
      severity_sort = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = " ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    },
    -- Inlay hints for modern Neovim
    inlay_hints = {
      enabled = true,
    },
    -- Global capabilities
    capabilities = {},
    -- Advanced formatting options
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    -- Complex server configuration system
    servers = {
      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            codeLens = {
              enable = true,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
    },
    -- Advanced setup hooks system
    setup = {
      -- Custom server setup functions
      -- ["*"] = function(server, opts) end,
    },
  },
  config = function(_, opts)
    local Util = require("util")
    
    -- Advanced neoconf integration
    if Util.has("neoconf.nvim") then
      local plugin = require("lazy.core.config").spec.plugins["neoconf.nvim"]
      require("neoconf").setup(require("lazy.core.plugin").values(plugin, "opts", false))
    end

    -- Complex autoformat system
    Util.format.register(Util.lsp.formatter())

    -- Dynamic keymaps system
    Util.lsp.on_attach(function(client, buffer)
      require("util.keymaps").on_attach(client, buffer)
    end)

    -- Advanced client capability registration
    local register_capability = vim.lsp.handlers["client/registerCapability"]
    vim.lsp.handlers["client/registerCapability"] = function(err, res, ctx)
      local ret = register_capability(err, res, ctx)
      local client_id = ctx.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      local buffer = vim.api.nvim_get_current_buf()
      require("util.keymaps").on_attach(client, buffer)
      return ret
    end

    -- Advanced diagnostics setup with icon prefix detection
    for name, icon in pairs(require("config.icons").diagnostics) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end

    -- Inlay hints system for modern Neovim
    local inlay_hint = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
    if opts.inlay_hints.enabled and inlay_hint then
      Util.lsp.on_attach(function(client, buffer)
        if client.supports_method("textDocument/inlayHint") then
          inlay_hint(buffer, true)
        end
      end)
    end

    -- Dynamic virtual text prefix system
    if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
      opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
        or function(diagnostic)
          local icons = require("config.icons").diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
        end
    end

    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    -- Complex server setup system with dynamic capability detection
    local servers = opts.servers
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      has_cmp and cmp_nvim_lsp.default_capabilities() or {},
      opts.capabilities or {}
    )

    local function setup(server)
      local server_opts = vim.tbl_deep_extend("force", {
        capabilities = vim.deepcopy(capabilities),
      }, servers[server] or {})

      if opts.setup[server] then
        if opts.setup[server](server, server_opts) then
          return
        end
      elseif opts.setup["*"] then
        if opts.setup["*"](server, server_opts) then
          return
        end
      end
      require("lspconfig")[server].setup(server_opts)
    end

    -- Advanced Mason integration with dynamic server detection
    local have_mason, mlsp = pcall(require, "mason-lspconfig")
    local all_mslp_servers = {}
    if have_mason then
      -- This line caused issues - dynamic server mapping
      all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
    end

    local ensure_installed = {}
    for server, server_opts in pairs(servers) do
      if server_opts then
        server_opts = server_opts == true and {} or server_opts
        if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
          setup(server)
        elseif server_opts.enabled ~= false then
          ensure_installed[#ensure_installed + 1] = server
        end
      end
    end

    -- Advanced Mason-LSPConfig integration
    if have_mason then
      mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
    end

    -- TypeScript/Deno conflict resolution system
    if Util.lsp.get_config("denols") and Util.lsp.get_config("tsserver") then
      local is_deno = require("lspconfig.util").root_pattern("deno.json", "deno.jsonc")
      Util.lsp.disable("tsserver", is_deno)
      Util.lsp.disable("denols", function(root_dir)
        return not is_deno(root_dir)
      end)
    end
  end,
}