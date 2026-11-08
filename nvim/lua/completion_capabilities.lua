-- LSP declarations supported by the pinned Blink v1, without loading its UI.
-- tests/deferred.lua checks parity against Blink's own capability helper.
local M = {}
function M.get()
  return vim.tbl_deep_extend('force', vim.lsp.protocol.make_client_capabilities(), {
    textDocument = { completion = {
      completionItem = {
        snippetSupport = true, commitCharactersSupport = false,
        documentationFormat = { 'markdown', 'plaintext' }, deprecatedSupport = true,
        preselectSupport = false, tagSupport = { valueSet = { 1 } }, insertReplaceSupport = true,
        resolveSupport = { properties = { 'documentation', 'detail', 'additionalTextEdits', 'command', 'data' } },
        insertTextModeSupport = { valueSet = { 1 } }, labelDetailsSupport = true,
      },
      completionList = { itemDefaults = { 'commitCharacters', 'editRange', 'insertTextFormat', 'insertTextMode', 'data' } },
      contextSupport = true, insertTextMode = 1,
    } },
  })
end
return M
