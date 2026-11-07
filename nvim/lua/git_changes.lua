local M = {}

local function run(root, args, callback)
  local cmd = { 'git', '-C', root, '--no-pager' }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = false }, vim.schedule_wrap(callback))
end

function M.status()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fn.filereadable(file) == 1 and vim.fs.dirname(file) or vim.fn.getcwd()
  run(dir, { 'rev-parse', '--show-toplevel' }, function(repo)
    if repo.code ~= 0 then vim.notify('Not inside a Git repository', vim.log.levels.INFO); return end
    local root = repo.stdout:gsub('\n$', '')
    run(root, { 'status', '--porcelain=v1', '-z', '--untracked-files=all' }, function(result)
      if result.code ~= 0 then vim.notify(result.stderr, vim.log.levels.ERROR); return end
      local entries, items, i = vim.split(result.stdout, '\0', { plain = true, trimempty = true }), {}, 1
      while i <= #entries do
        local entry = entries[i]
        local status, path = entry:sub(1, 2), entry:sub(4)
        local label = path
        if status:find('[RC]') then
          i = i + 1
          label = (entries[i] or '') .. ' → ' .. path
        end
        table.insert(items, {
          path = root .. '/' .. path, relative = path, status = status,
          text = status .. '  ' .. label:gsub('\n', '\\n'):gsub('\t', '\\t'),
        })
        i = i + 1
      end
      if #items == 0 then vim.notify('Git working tree is clean'); return end
      local pick = require('mini.pick')
      local function preview(buf, item)
        -- Each preview is asynchronous; ignore stale results after moving selection.
        local token = {}
        M.preview_token = token
        if item.status == '??' then return pick.default_preview(buf, item) end
        local outputs, pending = {}, 2
        local function display(section, diff)
          outputs[section] = diff.code == 0 and diff.stdout or diff.stderr
          pending = pending - 1
          if pending > 0 or M.preview_token ~= token or not vim.api.nvim_buf_is_valid(buf) then return end
          local lines = { 'STAGED', '' }
          vim.list_extend(lines, vim.split(outputs.staged or '', '\n', { plain = true }))
          vim.list_extend(lines, { '', 'UNSTAGED', '' })
          vim.list_extend(lines, vim.split(outputs.unstaged or '', '\n', { plain = true }))
          vim.bo[buf].modifiable = true
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].filetype = 'diff'
        end
        local flags = { '--no-ext-diff', '--no-textconv', '--no-color' }
        run(root, vim.list_extend({ 'diff', '--cached' }, vim.list_extend(vim.deepcopy(flags), { '--', item.relative })), function(r) display('staged', r) end)
        run(root, vim.list_extend({ 'diff' }, vim.list_extend(vim.deepcopy(flags), { '--', item.relative })), function(r) display('unstaged', r) end)
      end
      pick.start({ source = {
        name = 'Git changes · index/worktree status · Tab previews', cwd = root, items = items,
        preview = preview,
        choose = function(item)
          if vim.fn.filereadable(item.path) == 0 then
            vim.notify('File is deleted or unavailable; use Tab to inspect its diff', vim.log.levels.INFO)
            return true
          end
          pick.default_choose(item)
          vim.cmd('checktime')
        end,
      } })
    end)
  end)
end

return M
