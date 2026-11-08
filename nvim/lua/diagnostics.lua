local M = {}
local ready = false
function M.setup()
  if ready then return end
  vim.diagnostic.config({
    virtual_text = not vim.g.mobile and { spacing = 2 } or false,
    signs = not vim.g.mobile, underline = true,
    severity_sort = true, float = { border = 'rounded' },
  })
  ready = true
end
return M
