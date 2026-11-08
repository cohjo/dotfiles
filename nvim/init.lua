vim.g.mobile = vim.env.NVIM_MOBILE == "1"
vim.filetype.add({
  filename = {
    ['docker-compose.yml'] = 'yaml.docker-compose', ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['compose.yml'] = 'yaml.docker-compose', ['compose.yaml'] = 'yaml.docker-compose',
  },
})
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
local o = vim.opt
o.termguicolors = true
o.guifont = "Berkeley Mono:h16"
o.number = true
o.signcolumn = 'yes'
o.wrap = false
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.splitbelow = true
o.splitright = true
o.scrolloff = 5
o.updatetime = 250
o.timeoutlen = 400
o.clipboard = 'unnamedplus'
o.completeopt = 'menu,menuone,noselect'
vim.diagnostic.config({ virtual_text = { spacing = 2 }, severity_sort = true, float = { border = 'rounded' } })
vim.api.nvim_create_autocmd('BufReadPost', { callback = function(ev)
  local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
  if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
end })
vim.api.nvim_create_autocmd('TextYankPost', { callback = function() vim.highlight.on_yank() end })
if vim.g.mobile then require('mobile').setup() end
local lazy = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazy) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', 'https://github.com/folke/lazy.nvim.git', lazy })
  if vim.v.shell_error ~= 0 then error('Could not install lazy.nvim') end
end
vim.opt.rtp:prepend(lazy)
require('lazy').setup('plugins', { change_detection = { enabled = false }, rocks = { enabled = false } })
require('keymaps')
if vim.g.mobile then require('mobile').setup_actions() end
