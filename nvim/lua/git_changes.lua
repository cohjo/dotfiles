local M = {}

local function run(root, args, callback)
  local cmd = { 'git', '-C', root, '--no-pager' }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = false }, vim.schedule_wrap(callback))
end

local function current_dir()
  local file = vim.api.nvim_buf_get_name(0)
  return vim.fn.filereadable(file) == 1 and vim.fs.dirname(file) or vim.fn.getcwd()
end

local function choose_item(pick)
  return function(item)
    if vim.fn.filereadable(item.path) == 0 then
      vim.notify('File is deleted or unavailable; use Tab to inspect its diff', vim.log.levels.INFO)
      return true
    end
    pick.default_choose(item)
    vim.cmd('checktime')
  end
end

function M.status()
  run(current_dir(), { 'rev-parse', '--show-toplevel' }, function(repo)
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
      local pick = require('features').pick()
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
        preview = preview, choose = choose_item(pick),
      } })
    end)
  end)
end

-- Review committed branch or last-commit changes asynchronously (never blocks the UI).
function M.review_commits()
  run(current_dir(), { 'rev-parse', '--show-toplevel' }, function(repo)
    if repo.code ~= 0 then vim.notify('Not inside a Git repository', vim.log.levels.INFO); return end
    local root = repo.stdout:gsub('\n$', '')
    local candidates = { 'origin/HEAD', 'origin/main', 'origin/master', 'main', 'master' }
    local function open_diff(base_ref, label)
      run(root, { 'diff', '--name-status', '-z', base_ref }, function(result)
        if result.code ~= 0 then vim.notify(result.stderr, vim.log.levels.ERROR); return end
        local entries, items, i = vim.split(result.stdout, '\0', { plain = true, trimempty = true }), {}, 1
        while i <= #entries do
          local status = entries[i]
          local path = entries[i + 1] or ''
          local display_path = path
          if status:find('^[RC]') then
            local new_path = entries[i + 2] or path
            display_path = path .. ' → ' .. new_path
            path = new_path
            i = i + 3
          else
            i = i + 2
          end
          table.insert(items, {
            path = root .. '/' .. path, relative = path, status = status,
            text = string.format('%-4s %s', status, display_path:gsub('\n', '\\n'):gsub('\t', '\\t')),
          })
        end
        if #items == 0 then
          if base_ref ~= 'HEAD~1' then
            open_diff('HEAD~1', 'HEAD~1..HEAD')
          else
            vim.notify('No committed changes found to review', vim.log.levels.INFO)
          end
          return
        end
        local pick = require('features').pick()
        local function preview(buf, item)
          local token = {}
          M.preview_token = token
          run(root, { 'diff', '--no-ext-diff', '--no-textconv', '--no-color', base_ref, '--', item.relative }, function(diff)
            if M.preview_token ~= token or not vim.api.nvim_buf_is_valid(buf) then return end
            local out = diff.code == 0 and diff.stdout or diff.stderr
            local lines = vim.split(out or '', '\n', { plain = true })
            vim.bo[buf].modifiable = true
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].filetype = 'diff'
          end)
        end
        pick.start({ source = {
          name = 'Git review (' .. label .. ') · Tab previews diff', cwd = root, items = items,
          preview = preview, choose = choose_item(pick),
        } })
      end)
    end
    local function try_candidate(idx)
      local ref = candidates[idx]
      if not ref then
        open_diff('HEAD~1', 'HEAD~1..HEAD')
        return
      end
      run(root, { 'merge-base', 'HEAD', ref }, function(mb)
        local base = mb.code == 0 and mb.stdout:gsub('%s+$', '') or ''
        if base ~= '' then
          run(root, { 'rev-parse', 'HEAD' }, function(head)
            local head_sha = head.code == 0 and head.stdout:gsub('%s+$', '') or ''
            if head_sha ~= '' and head_sha ~= base then
              open_diff(base, ref .. '...HEAD')
            else
              try_candidate(idx + 1)
            end
          end)
        else
          try_candidate(idx + 1)
        end
      end)
    end
    try_candidate(1)
  end)
end

-- Copy relative filepath:line (or visual line range) for AI agent prompts.
function M.yank_reference(visual)
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then vim.notify('Current buffer has no file path', vim.log.levels.INFO); return end
  local rel = vim.fn.fnamemodify(file, ':.')
  local l1, l2
  if visual then
    l1, l2 = vim.fn.line('v'), vim.fn.line('.')
    if l1 > l2 then l1, l2 = l2, l1 end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  else
    l1 = vim.api.nvim_win_get_cursor(0)[1]
    l2 = l1
  end
  local ref = l1 == l2 and string.format('%s:%d', rel, l1) or string.format('%s:%d-%d', rel, l1, l2)
  pcall(vim.fn.setreg, '"', ref)
  if not vim.g.mobile then pcall(vim.fn.setreg, '+', ref) end
  vim.notify('Copied reference: ' .. ref)
end

return M
