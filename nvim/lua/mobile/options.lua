local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.termguicolors = true
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes:1"
opt.cursorline = false
opt.wrap = false
opt.linebreak = true
opt.breakindent = true
opt.scrolloff = 3
opt.sidescrolloff = 6
opt.laststatus = 2
opt.showmode = false
opt.cmdheight = 1
opt.splitbelow = true
opt.splitright = true
opt.mouse = ""

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"
opt.updatetime = 300
opt.timeoutlen = 500
opt.completeopt = { "menu", "menuone", "noselect" }

opt.undofile = true
opt.swapfile = false
opt.backup = false

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
  },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
