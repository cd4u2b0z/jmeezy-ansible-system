-- Neovim Options Configuration
local opt = vim.opt

-- General
opt.clipboard = "unnamedplus" -- sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- hide * markup for bold and italic
opt.confirm = true -- confirm to save changes before exiting modified buffer
opt.cursorline = true -- enable highlighting of the current line
opt.expandtab = true -- use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3 -- global statusline
opt.list = true -- show some invisible characters (tabs...
opt.mouse = "a" -- enable mouse mode
opt.number = true -- print line number
opt.pumblend = 10 -- popup blend
opt.pumheight = 10 -- maximum number of entries in a popup
opt.relativenumber = true -- relative line numbers
opt.scrolloff = 4 -- lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true -- round indent
opt.shiftwidth = 2 -- size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- dont show mode since we have a statusline
opt.sidescrolloff = 8 -- columns of context
opt.signcolumn = "no" -- always show the signcolumn
opt.smartcase = true -- don't ignore case with capitals
opt.smartindent = true -- insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- put new windows below current
opt.splitright = true -- put new windows right of current
opt.tabstop = 2 -- number of spaces tabs count for
opt.termguicolors = true -- true color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- command-line completion mode
opt.winminwidth = 5 -- minimum window width
opt.wrap = false -- disable line wrap

-- Folding
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Nord theme specific
vim.g.nord_italic = true
vim.g.nord_bold = true
vim.g.nord_underline = true
-- Force solid background on line numbers (remove frosted effect)
vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
  callback = function()
    local bg = vim.api.nvim_get_hl(0, {name = "Normal"}).bg
    if bg then
      local hex = string.format("#%06x", bg)
      vim.api.nvim_set_hl(0, "LineNr", { fg = vim.api.nvim_get_hl(0, {name = "LineNr"}).fg, bg = hex })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = vim.api.nvim_get_hl(0, {name = "CursorLineNr"}).fg, bg = hex, bold = true })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = hex })
      vim.api.nvim_set_hl(0, "FoldColumn", { bg = hex })
    end
  end,
})
