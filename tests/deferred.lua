-- DOTFILES_BOOTSTRAP=1 nvim --headless '+luafile tests/deferred.lua'
local ok, err = pcall(function()
  assert(vim.g.colors_name == 'tokyonight-night', 'Theme must be ready before first draw')
  assert(not package.loaded['mini.pick'] and not package.loaded['mini.extra'])
  assert(not package.loaded['mini.ai'] and not package.loaded['mini.pairs'])
  assert(not package.loaded['blink.cmp'] and not package.loaded['gitsigns'])
  assert(not package.loaded['treesitter-context'], 'Treesitter context must stay deferred after first draw')
  assert(not package.loaded['mason'] and not package.loaded['mason-tool-installer'])
  assert(vim.g.loaded_python3_provider == 0, 'Legacy remote Python provider must stay disabled')
  assert((package.loaded['mini.statusline'] ~= nil) == (not vim.g.mobile), 'Visible statusline should not pop in later')
  print('PASS: theme/chrome ready, functional modules deferred')

  -- Test a real first-insert keystroke, not merely an autocommand invocation.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('i(<Esc>', true, false, true), 'xt', false)
  assert(vim.api.nvim_get_current_line() == '()', 'First typed bracket was not paired')
  assert(package.loaded['mini.pairs'], 'Pairing did not initialize')
  print('PASS: first insertion pairs without dropping or duplicating a character')

  vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'call(first, second)' })
  vim.api.nvim_win_set_cursor(0, { 1, 6 })
  vim.api.nvim_feedkeys('dia', 'xt', false)
  assert(package.loaded['mini.ai'], 'Text objects did not initialize before first operator')
  assert(vim.api.nvim_get_current_line():find('first', 1, true) == nil, 'First argument text object failed')
  print('PASS: first text-object operator works immediately')

  local caps = require('completion_capabilities').get()
  local blink = require('blink.cmp')
  assert(vim.deep_equal(caps, blink.get_lsp_capabilities(nil, true)), 'Capability snapshot differs from pinned Blink')
  print('PASS: deferred completion advertises Blink-compatible LSP capabilities')

  require('lazy').load({ plugins = { 'gitsigns.nvim' } })
  local gs_config = require('gitsigns.config').config
  assert(gs_config.current_line_blame == not vim.g.mobile, 'Inline Git blame default mismatch')
  assert(gs_config.current_line_blame_opts.delay == 300, 'Inline Git blame delay was not applied')
  print('PASS: deferred gitsigns enables lazy inline current-line blame')

  local pick = require('features').pick()
  local popup_ready = false
  vim.defer_fn(function()
    popup_ready = pick.is_picker_active()
    vim.api.nvim_input('<Esc>')
  end, 100)
  require('shortcuts').show_daily()
  assert(popup_ready and not pick.is_picker_active(), 'First picker did not open/close')
  assert(pick.config.mappings.move_down == '<Down>', 'Picker configuration was not applied on first open')
  print('PASS: first picker has final configuration and Escape closes it')

  vim.api.nvim_buf_set_name(0, vim.fn.getcwd() .. '/nvim/init.lua')
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  require('git_changes').yank_reference(false)
  assert(vim.fn.getreg('"') == 'nvim/init.lua:1', 'Yank reference did not format relative file:line')
  print('PASS: AI prompt reference yanks relative file:line without blocking')
end)
if not ok then print(err); vim.cmd('cquit') else vim.cmd('qa!') end
