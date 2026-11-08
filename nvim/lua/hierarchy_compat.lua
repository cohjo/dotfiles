-- Lifetime guard for the pinned meow.yarn/nui preview callback.
-- A scheduled preview can outlive a placeholder/no-symbol window or an Esc close.
local M = {}

function M.setup()
  local Hierarchy = require('meow.yarn.hierarchy')
  if Hierarchy._dotfiles_lifetime_guard then return end
  Hierarchy._dotfiles_lifetime_guard = true
  local setup_preview = Hierarchy._setup_preview
  Hierarchy._setup_preview = function(self)
    local get_node = self.tree.get_node
    self.tree.get_node = function(tree, id, ...)
      if id == nil and not self:is_valid() then return nil end
      return get_node(tree, id, ...)
    end
    setup_preview(self)
  end
  local setup_keys = Hierarchy._setup_keymaps
  Hierarchy._setup_keymaps = function(self)
    setup_keys(self)
    for _, popup in ipairs({ self.tree_popup, self.preview_popup }) do
      for _, key in ipairs({ '<Esc>', 'q' }) do
        vim.keymap.set('n', key, function() self:unmount() end, {
          buffer = popup.bufnr, nowait = true, silent = true, desc = 'Close hierarchy',
        })
      end
    end
  end
end

return M
