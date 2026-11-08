local M = {}

local function attempt(action)
  local ok, err = pcall(action)
  if not ok then vim.notify(tostring(err), vim.log.levels.WARN) end
  return ok
end

function M.quit(all)
  attempt(function() vim.cmd(all and 'qall' or 'quit') end)
end

-- Keep the buffer explicit across asynchronous filename prompts. Cancel/error
-- never runs on_saved, so save-and-quit cannot exit after an unsuccessful save.
function M.save(on_saved, buf, save_as)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  if vim.bo[buf].buftype ~= '' then
    vim.notify('Select a file buffer before saving.', vim.log.levels.INFO)
    return
  end
  local function write(path)
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local ok = attempt(function()
      vim.api.nvim_buf_call(buf, function()
        if path then
          vim.cmd({ cmd = 'saveas', args = { vim.fn.fnamemodify(path, ':p') } })
        else
          vim.cmd('write')
        end
      end)
    end)
    if ok and on_saved then on_saved() end
  end
  local name = vim.api.nvim_buf_get_name(buf)
  if save_as or name == '' then
    vim.ui.input({ prompt = 'Save as: ', default = save_as and name or '', completion = 'file' }, function(path)
      if path and path ~= '' then write(path) end
    end)
  else
    write()
  end
end

function M.save_quit()
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  M.save(function()
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_win_call(win, function() M.quit(false) end)
    end
  end, buf)
end

function M.save_all_quit()
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified and vim.bo[buf].buftype == '' then
      table.insert(buffers, buf)
    end
  end
  local function next_buffer(index)
    local buf = buffers[index]
    if not buf then M.quit(true); return end
    M.save(function() next_buffer(index + 1) end, buf)
  end
  next_buffer(1)
end

return M
