-- Run: DOTFILES_BOOTSTRAP=1 NVIM_MOBILE=1 nvim --headless '+luafile tests/mobile_actions.lua'
local ok, err = pcall(function()
  assert(vim.g.mobile, 'Run this regression check with NVIM_MOBILE=1')
  local actions = require('mobile_actions')
  local original_input, original_notify = vim.ui.input, vim.notify
  local notifications = {}
  vim.notify = function(message) table.insert(notifications, message) end
  local function key(lhs) vim.fn.maparg(' ' .. lhs, 'n', false, true).callback() end
  local root = vim.fn.tempname()
  vim.fn.mkdir(root, 'p')
  local function fresh(text)
    vim.cmd('enew!')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { text })
    return vim.api.nvim_get_current_buf()
  end
  local buf = fresh('phone edit')
  key('qq')
  assert(vim.api.nvim_buf_is_valid(buf) and vim.bo.modified, 'Quit discarded unsaved text')
  key('qa')
  assert(vim.api.nvim_buf_is_valid(buf) and vim.bo.modified, 'Quit all discarded unsaved text')
  assert(#notifications >= 2, 'Unsaved quit should explain why it was blocked')
  vim.ui.input = function(_, callback) callback(nil) end
  key('qs')
  assert(vim.bo.modified, 'Cancelled Save As must not quit or discard')
  local path = root .. '/new note | literal.txt'
  vim.ui.input = function(_, callback) callback(path) end
  key('w')
  assert(vim.fn.readfile(path)[1] == 'phone edit', 'New-file save or literal filename handling failed')
  assert(not vim.bo.modified, 'Successful save should clear modified state')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'updated text' })
  key('w')
  assert(vim.fn.readfile(path)[1] == 'updated text', 'Named-file save failed')
  local existing = root .. '/existing.txt'
  vim.fn.writefile({ 'retain existing content' }, existing)
  vim.ui.input = function(_, callback) callback(existing) end
  key('a')
  assert(vim.fn.readfile(existing)[1] == 'retain existing content', 'Save As force-overwrote a file')
  fresh('must stay open')
  vim.ui.input = function(_, callback) callback(root .. '/missing-directory/file.txt') end
  local saved = false
  actions.save(function() saved = true end)
  assert(not saved and vim.bo.modified, 'Failed save must not call the quit continuation')
  fresh('unnamed text')
  vim.ui.input = function(_, callback) callback(nil) end
  key('qw')
  assert(vim.bo.modified, 'Cancelled save-all must not quit')
  vim.ui.input, vim.notify = original_input, original_notify
  print('PASS ALL: mobile saves, filename prompts, cancellation, literal paths, overwrite protection and safe quitting')
end)
if not ok then print(err); vim.cmd('cquit') else vim.cmd('qa!') end
