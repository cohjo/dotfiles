local M = {}

function M.dismiss()
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  -- Let compound plugin windows run their own cleanup, rather than closing their
  -- individual floating windows and leaving callbacks/resources behind.
  local pick = package.loaded['mini.pick']
  if pick and pick.is_picker_active() then pick.stop(); return end
  if ft == 'lazy' and package.loaded['lazy.view'] then
    local view = require('lazy.view').view
    if view then view:close(); return end
  end
  local blink = package.loaded['blink.cmp']
  if blink then blink.hide() end
  for _, popup in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_is_valid(popup) and vim.api.nvim_win_get_config(popup).relative ~= '' then
      local origin = vim.w[popup].lsp_floating_bufnr
      if origin == buf or (popup == win and origin ~= nil) or vim.w[popup].gitsigns_preview ~= nil then
        vim.api.nvim_win_close(popup, true)
      end
    end
  end
  vim.cmd.nohlsearch()
end

return M
