local M = {}

-- Curated daily essentials, not usage tracking. The full live mapping list is Space ?.
M.daily = {
  { ' f', 'Space f', 'Files', 'Find a file by name' },
  { ' b', 'Space b', 'Files', 'Switch open buffers' },
  { ' /', 'Space /', 'Files', 'Search text across the project' },
  { 'H', 'Shift h', 'Files', 'Previous buffer' },
  { 'L', 'Shift l', 'Files', 'Next buffer' },
  { ' w', 'Space w', 'Files', 'Save file' },
  { ' x', 'Space x', 'Files', 'Close buffer' },
  { 'gd', 'gd', 'Code', 'Go to definition' },
  { 'gr', 'gr', 'Code', 'Find references' },
  { 'gi', 'gi', 'Code', 'Go to implementation' },
  { 'K', 'K', 'Code', 'Show documentation' },
  { ' s', 'Space s', 'Code', 'Find a symbol in this file' },
  { ' j', 'Space j', 'Code', 'Back through navigation history' },
  { ' k', 'Space k', 'Code', 'Forward through navigation history' },
  { ' ci', 'Space ci', 'Code', 'Who calls this function?' },
  { ' co', 'Space co', 'Code', 'What does this function call?' },
  { ' rn', 'Space rn', 'Change', 'Rename symbol across files' },
  { ' ca', 'Space ca', 'Change', 'Code actions and suggested fixes' },
  { ' lf', 'Space lf', 'Change', 'Format file' },
  { ' d', 'Space d', 'Problems', 'Explain diagnostic at cursor' },
  { ']d', ']d', 'Problems', 'Next diagnostic' },
  { '[d', '[d', 'Problems', 'Previous diagnostic' },
  { 'w', 'w / b', 'Motion', 'Next word (b goes back)' },
  { '%', '%', 'Motion', 'Jump to matching bracket' },
  { '*', '*', 'Search', 'Search for word under cursor' },
  { 'n', 'n / N', 'Search', 'Next match (N goes back)' },
  { 'ciw', 'ciw', 'Edit', 'Change the word under cursor' },
  { 'ci"', 'ci"', 'Edit', 'Change text inside double quotes' },
  { 'gcc', 'gcc', 'Edit', 'Toggle comment on current line' },
  { 'yy', 'yy', 'Edit', 'Copy line' },
  { 'p', 'p', 'Edit', 'Paste after cursor or line' },
  { 'u', 'u', 'Edit', 'Undo' },
  { '<Cmd>redo<CR>', ':redo', 'Edit', 'Redo without Ctrl' },
  { ' gs', 'Space gs', 'Git', 'Browse all changed files (Git status)' },
  { ' gd', 'Space gd', 'Git', 'Browse unstaged diffs by hunk' },
  { ' gD', 'Space gD', 'Git', 'Browse staged diffs by hunk' },
  { ' hp', 'Space hp', 'Git', 'Preview changed hunk' },
  { ' ?', 'Space ?', 'Help', 'Search every normal-mode mapping' },
}

if vim.g.mobile then
  vim.list_extend(M.daily, {
    { ' z', 'Space z', 'Mobile', 'Page down' },
    { ' u', 'Space u', 'Mobile', 'Page up' },
    { ' n', 'Space n', 'Mobile', 'Toggle line numbers' },
    { ' tf', 'Space tf', 'Mobile', 'Toggle format on save for this buffer' },
  })
end

function M.show_daily()
  local items = {}
  for _, entry in ipairs(M.daily) do
    table.insert(items, {
      keys = entry[1],
      text = string.format('%-11s  %-8s  %s', entry[2], entry[3], entry[4]),
    })
  end
  require('mini.pick').start({ source = {
    name = 'Daily keys · type to search · Enter runs · Esc closes',
    items = items,
    choose = function(item)
      local keys = vim.api.nvim_replace_termcodes(item.keys, true, true, true)
      vim.schedule(function() vim.api.nvim_input(keys) end)
    end,
  } })
end

return M
