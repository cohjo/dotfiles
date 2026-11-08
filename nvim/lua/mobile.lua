local M = {}

function M.setup()
  local o = vim.opt
  o.number = false
  o.relativenumber = false
  o.signcolumn = 'no'
  o.wrap = true
  o.linebreak = true
  o.breakindent = true
  o.showbreak = '> '
  o.scrolloff = 2
  o.sidescrolloff = 1
  o.laststatus = 0
  o.showmode = true
  o.showcmd = false
  o.ruler = false
  o.pumheight = 6
  o.mouse = 'a'
  o.clipboard = '' -- no remote OS clipboard calls; use the client's copy/paste.
  vim.diagnostic.config({ virtual_text = false, signs = false })
  -- Avoid formatting a whole file or blocking a short phone edit on save.
  local function disable_format(ev)
    if vim.b[ev.buf].disable_autoformat == nil then vim.b[ev.buf].disable_autoformat = true end
  end
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, { callback = disable_format })
  disable_format({ buf = vim.api.nvim_get_current_buf() })
  local map = vim.keymap.set
  for _, key in ipairs({ 'j', 'k' }) do
    map('n', key, function() return vim.v.count == 0 and 'g' .. key or key end, { expr = true, desc = 'Move by displayed line' })
  end
  map('n', '<leader>z', '<C-d>', { desc = 'Page down (mobile)' })
  map('n', '<leader>u', '<C-u>', { desc = 'Page up (mobile)' })
  map('n', '<leader>n', function() vim.wo.number = not vim.wo.number end, { desc = 'Toggle line numbers (mobile)' })
  map('i', 'jk', '<Esc>', { desc = 'Leave insert mode (mobile)' })
end

return M
