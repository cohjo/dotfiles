-- Run with the normal config loaded: nvim --headless '+luafile ...'.
require('lazy').load({ plugins = { 'nvim-lspconfig', 'nvim-treesitter' } })
local registry = require('mason-registry')
local packages = require('toolchain').packages()
local refreshed, refresh_ok = false, false
registry.refresh(function(ok) refresh_ok, refreshed = ok, true end)
if not vim.wait(120000, function() return refreshed end, 100) or not refresh_ok then
  vim.api.nvim_err_writeln('Mason registry refresh failed; check network access and :MasonLog')
  vim.cmd('cquit')
end
for _, name in ipairs(packages) do
  if not registry.has_package(name) then error('Unknown Mason package: ' .. name) end
  local pkg = registry.get_package(name)
  if not pkg:is_installed() and not pkg:is_installing() then
    print('Installing ' .. name)
    pkg:install()
  end
end
local done = vim.wait(600000, function()
  for _, name in ipairs(packages) do
    local pkg = registry.get_package(name)
    if pkg:is_installing() then return false end
  end
  return true
end, 500)
local missing = {}
for _, name in ipairs(packages) do
  if not registry.get_package(name):is_installed() then table.insert(missing, name) end
end
if not done or #missing > 0 then
  vim.api.nvim_err_writeln('Tool installation failed or timed out: ' .. table.concat(missing, ', ') .. '. See :MasonLog')
  vim.cmd('cquit')
end
vim.cmd('TSUpdateSync')
for _, parser in ipairs(require('toolchain').parsers) do
  local loaded, err = vim.treesitter.language.add(parser)
  if not loaded then error(err or ('Missing parser: ' .. parser)) end
  vim.treesitter.query.get(parser, 'highlights')
end
print('Neovim toolchain ready: ' .. #packages .. ' Mason packages')
vim.cmd('qa')
