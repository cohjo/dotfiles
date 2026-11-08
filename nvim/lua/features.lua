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

return M
