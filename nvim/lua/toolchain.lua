-- The source of truth for fresh-machine installs. Keys are lspconfig names;
-- values and formatters are Mason package names.
local M = {}
M.servers = {
  ty = 'ty', ruff = 'ruff', jdtls = 'jdtls',
  ts_ls = 'typescript-language-server', oxlint = 'oxlint',
  html = 'html-lsp', cssls = 'css-lsp',
  jsonls = 'json-lsp', yamlls = 'yaml-language-server',
  sqls = 'sqls', bashls = 'bash-language-server',
  dockerls = 'dockerfile-language-server',
  docker_compose_language_service = 'docker-compose-language-service',
  taplo = 'taplo', marksman = 'marksman', lua_ls = 'lua-language-server',
}
M.formatters = { 'prettier', 'stylua', 'shfmt', 'sql-formatter', 'shellcheck' }
M.parsers = {
  'python', 'java', 'javascript', 'typescript', 'tsx', 'html', 'css', 'sql',
  'lua', 'vim', 'vimdoc', 'bash', 'json', 'jsonc', 'toml', 'yaml',
  'dockerfile', 'markdown', 'markdown_inline',
}
function M.packages()
  local packages = vim.tbl_values(M.servers)
  vim.list_extend(packages, M.formatters)
  table.sort(packages)
  return packages
end
return M
