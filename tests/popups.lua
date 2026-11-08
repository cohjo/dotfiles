-- Run against the linked config: DOTFILES_BOOTSTRAP=1 nvim --headless '+luafile tests/popups.lua'
local function check(ok, message) assert(ok, message); print('PASS: ' .. message) end
local ok, err = pcall(function()
  local source = vim.api.nvim_get_current_buf()
  local source_win = vim.api.nvim_get_current_win()
  vim.api.nvim_buf_set_name(source, vim.fn.tempname() .. '.txt')
  vim.api.nvim_buf_set_lines(source, 0, -1, false, { 'function example() {}' })
  local yarn = require('meow.yarn') -- also installs the dotfiles compatibility guard
  local util = require('meow.yarn.util')
  local state = require('meow.yarn.state').G
  local strategy = require('meow.yarn.strategies.call')
  local original_find = util.lsp.find_client
  local reply = {}
  local fake = { offset_encoding = 'utf-16', server_capabilities = { callHierarchyProvider = true }, cancel_request = function() end }
  fake.request = function(_, _, callback)
    vim.defer_fn(function() callback(nil, reply) end, 30)
    return true, 1
  end
  util.lsp.find_client = function() return fake end
  local function active()
    for _, h in pairs(state.active_hierarchies) do if h:is_valid() then return h end end
  end
  local function close_with_escape(h)
    vim.api.nvim_set_current_win(h.tree_popup.winid)
    local mapping = vim.fn.maparg('<Esc>', 'n', false, true)
    check(type(mapping.callback) == 'function', 'hierarchy has an Escape close action')
    mapping.callback()
  end
  yarn.open_tree('call_hierarchy', 'callers')
  check(vim.wait(2000, function() return active() == nil end, 20), 'empty LSP response closes the no-symbol placeholder')
  vim.api.nvim_set_current_win(source_win)
  yarn.open_tree('call_hierarchy', 'callees')
  local pending = assert(active())
  close_with_escape(pending)
  vim.wait(100, function() return false end, 10)
  check(active() == nil, 'Escape closes a pending hierarchy and ignores the late LSP reply')

  -- Reproduce the reported race exactly: the debounce timer has queued a
  -- preview callback, then the popup closes before that callback executes.
  local range = { start = { line = 0, character = 0 }, ['end'] = { line = 0, character = 8 } }
  local item = { name = 'example', kind = 12, uri = vim.uri_from_bufnr(source), range = range, selectionRange = range }
  vim.api.nvim_set_current_win(source_win)
  local h = require('meow.yarn.hierarchy'):new(fake, item, strategy, 'callers')
  h:mount()
  vim.wait(30, function() return false end, 10)
  local schedule, queue = vim.schedule, {}
  vim.schedule = function(callback) table.insert(queue, callback) end
  vim.api.nvim_exec_autocmds('CursorMoved', { buffer = h.tree.bufnr })
  vim.wait(150, function() return false end, 10)
  vim.schedule = schedule
  close_with_escape(h)
  check(#queue > 0, 'preview debounce queued a callback before close')
  for _, callback in ipairs(queue) do callback() end
  check(active() == nil, 'queued preview callbacks safely handle a destroyed hierarchy')
  util.lsp.find_client = original_find

  vim.api.nvim_set_current_win(source_win)
  local _, preview = vim.lsp.util.open_floating_preview({ 'hover documentation' }, 'plaintext')
  require('popups').dismiss()
  check(not vim.api.nvim_win_is_valid(preview), 'Escape dismisses LSP preview from source window')
  local _, focused = vim.lsp.util.open_floating_preview({ 'diagnostic details' }, 'plaintext')
  vim.api.nvim_set_current_win(focused)
  require('popups').dismiss()
  check(not vim.api.nvim_win_is_valid(focused), 'Escape dismisses focused LSP preview')

  local buf = vim.api.nvim_create_buf(false, true)
  local git_preview = vim.api.nvim_open_win(buf, false, { relative = 'editor', row = 1, col = 1, width = 20, height = 2 })
  vim.w[git_preview].gitsigns_preview = 'hunk'
  require('popups').dismiss()
  check(not vim.api.nvim_win_is_valid(git_preview), 'Escape dismisses Git hunk previews')
  local pick = require('features').pick()
  vim.defer_fn(function() vim.api.nvim_input('<Esc>') end, 100)
  pick.start({ source = { items = { 'one', 'two' } } })
  check(not pick.is_picker_active(), 'Escape closes picker event loop')
  -- Package managers have compound views and need their own close methods.
  vim.api.nvim_set_current_win(source_win)
  vim.cmd('Mason')
  vim.wait(100, function() return false end, 20)
  local mason_win = vim.api.nvim_get_current_win()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'xt', false)
  check(vim.wait(1000, function() return not vim.api.nvim_win_is_valid(mason_win) end, 20), 'Mason Escape closes through its UI cleanup')
  local lazy_view = require('lazy.view')
  lazy_view.view = lazy_view.create()
  local lazy_win = lazy_view.view.win
  vim.api.nvim_set_current_win(lazy_win)
  require('popups').dismiss()
  vim.wait(50, function() return false end, 10)
  check(not vim.api.nvim_win_is_valid(lazy_win), 'Escape closes Lazy through its UI cleanup')
  check(vim.api.nvim_win_is_valid(source_win), 'Escape leaves the source editor window intact')
  check(not vim.v.errmsg:find("Invalid 'window'", 1, true), 'no asynchronous invalid-window error')
end)
if not ok then print(err); vim.cmd('cquit') else vim.cmd('qa!') end
