local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format", "ruff_organize_imports" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    yaml = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
    sh = { "shfmt" },
    zsh = { "shfmt" },
    go = { "gofmt", "goimports" },
    rust = { "rustfmt", lsp_format = "fallback" },
  },
  format_on_save = function(bufnr)
    local disabled = vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat
    if disabled then
      return
    end

    return {
      timeout_ms = 800,
      lsp_format = "fallback",
    }
  end,
})

vim.api.nvim_create_user_command("Format", function(args)
  conform.format({
    async = args.bang,
    lsp_format = "fallback",
  })
end, { bang = true })

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {})
