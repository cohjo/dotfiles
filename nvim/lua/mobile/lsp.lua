local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, blink = pcall(require, "blink.cmp")
if ok then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

local servers = {
  lua_ls = "lua-language-server",
  pyright = "pyright-langserver",
  ts_ls = "typescript-language-server",
  bashls = "bash-language-server",
  jsonls = "vscode-json-language-server",
  yamlls = "yaml-language-server",
  marksman = "marksman",
  taplo = "taplo",
  rust_analyzer = "rust-analyzer",
  gopls = "gopls",
}

local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

local missing = {}
for server, executable in pairs(servers) do
  if vim.fn.executable(executable) == 1 then
    vim.lsp.config(server, vim.tbl_deep_extend("force", {
      capabilities = capabilities,
    }, server_configs[server] or {}))
    vim.lsp.enable(server)
  else
    table.insert(missing, executable)
  end
end

vim.api.nvim_create_user_command("MobileLspMissing", function()
  if #missing == 0 then
    vim.notify("All configured language servers are available")
    return
  end
  vim.notify("Missing language servers: " .. table.concat(missing, ", "))
end, {})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then
      return
    end

    -- Keep mobile editing calm. Ask for diagnostics/hover when needed.
    if client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
    end
  end,
})
