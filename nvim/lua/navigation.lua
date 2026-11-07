local M = {}

function M.hierarchy(kind, direction)
  local method = kind == 'call_hierarchy' and 'textDocument/prepareCallHierarchy' or 'textDocument/prepareTypeHierarchy'
  if #vim.lsp.get_clients({ bufnr = 0, method = method }) == 0 then
    vim.notify('The current language server does not support this hierarchy. Try gr for references or Space s for symbols.', vim.log.levels.INFO)
    return
  end
  require('meow.yarn').open_tree(kind, direction)
end

return M
