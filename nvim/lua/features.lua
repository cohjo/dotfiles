-- Functional modules initialize on first use; visible chrome stays in plugins.lua.
local M = {}
local pick_ready, extra_ready = false, false

function M.pick()
  local pick = require('mini.pick')
  if not pick_ready then
    pick.setup({
      source = { show = function(buf, items, query)
        pick.default_show(buf, items, query, { show_icons = false })
      end },
      window = { config = vim.g.mobile and function()
        return { width = math.max(1, vim.o.columns - 2), height = math.max(1, math.min(12, vim.o.lines - 4)) }
      end or nil },
      mappings = { move_down = '<Down>', move_up = '<Up>', toggle_preview = '<Tab>', stop = '<Esc>' },
    })
    pick_ready = true
  end
  return pick
end

function M.extra()
  M.pick()
  local extra = require('mini.extra')
  if not extra_ready then extra.setup(); extra_ready = true end
  return extra
end

function M.ast_grep()
  local bin = vim.fn.executable('sg') == 1 and 'sg' or (vim.fn.executable('ast-grep') == 1 and 'ast-grep' or nil)
  if not bin then
    vim.notify('ast-grep (sg) is not installed; run brew install ast-grep', vim.log.levels.WARN)
    return
  end
  local pick = M.pick()
  local cwd = vim.fn.getcwd()
  local set_items_opts = { do_match = false, querytick = pick.get_querytick() }
  local spawn_opts = { cwd = cwd }
  local sys = { kill = function() end }
  local function postprocess(lines)
    local items = {}
    for _, line in ipairs(lines) do
      local path, lnum, col, rest = line:match('^([^:]+):(%d+):(%d+):(.*)$')
      if path then
        table.insert(items, {
          path = path, lnum = tonumber(lnum), col = tonumber(col),
          text = string.format('%s:%s:%s:%s', path, lnum, col, rest),
        })
      end
    end
    return items
  end
  local function match(_, _, query)
    sys:kill()
    local tick = pick.get_querytick()
    if tick == set_items_opts.querytick then return end
    local pattern = vim.trim(table.concat(query))
    if #pattern < 2 then
      sys = { kill = function() end }
      return pick.set_picker_items({}, set_items_opts)
    end
    set_items_opts.querytick = tick
    sys = pick.set_picker_items_from_cli(
      { bin, 'run', '--color=never', '--heading=never', '-p', pattern },
      { postprocess = postprocess, set_items_opts = set_items_opts, spawn_opts = spawn_opts }
    )
  end
  pick.start({
    source = {
      name = 'AST search (ast-grep) · type code pattern (e.g. $A.setup($$$))',
      cwd = cwd, items = {}, match = match,
    },
  })
end

return M
