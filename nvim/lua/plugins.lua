return {
  { 'folke/tokyonight.nvim', priority = 1000, config = function()
    require('tokyonight').setup({ style = 'night' })
    vim.cmd.colorscheme('tokyonight')
  end },
  { 'nvim-mini/mini.nvim', config = function()
    require('mini.pick').setup({ mappings = {
      move_down = '<Down>', move_up = '<Up>', toggle_preview = '<Tab>',
    } })
    require('mini.extra').setup()
    require('mini.pairs').setup()
    require('mini.ai').setup()
    require('mini.statusline').setup({ use_icons = false })
  end },
  { 'retran/meow.yarn.nvim', main = 'meow.yarn', lazy = true, cmd = 'MeowYarn',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      expand_depth = 1,
      mappings = {
        preview_scroll_down = '<PageDown>', preview_scroll_up = '<PageUp>',
        toggle_select = 'm', send_to_quickfix = 'Q',
      },
      quickfix = { use_trouble = false },
    },
  },
  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },
  { 'lewis6991/gitsigns.nvim', event = { 'BufReadPre', 'BufNewFile' }, opts = {} },
  { 'saghen/blink.cmp', version = '1.*', event = 'InsertEnter', opts = {
    keymap = { preset = 'default' },
    completion = { documentation = { auto_show = true } },
    fuzzy = { implementation = 'lua' },
    signature = { enabled = true },
  } },
  { 'neovim/nvim-lspconfig', event = { 'BufReadPre', 'BufNewFile' }, dependencies = {
    { 'mason-org/mason.nvim', cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonLog' }, opts = {} },
    'mason-org/mason-lspconfig.nvim',
    { 'b0o/SchemaStore.nvim', lazy = true },
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  }, config = function()
    local capabilities = require('blink.cmp').get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
    -- Avoid macOS recursive file-watcher exhaustion on large workspaces.
    capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }
    vim.lsp.config('*', { capabilities = capabilities })
    -- Neovim 0.11 lacks this handler; current web servers request refreshes.
    if not vim.lsp.handlers['workspace/diagnostic/refresh'] then
      vim.lsp.handlers['workspace/diagnostic/refresh'] = function(_, _, ctx)
        vim.lsp.util._refresh('textDocument/diagnostic', { client_id = ctx.client_id, only_visible = true })
        return vim.NIL
      end
    end
    -- Ruff owns linting/actions/formatting; ty owns navigation and completion.
    vim.api.nvim_create_autocmd('LspAttach', { callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name == 'ruff' then client.server_capabilities.hoverProvider = false end
    end })
    -- A distinct Java workspace for every project, including projects with the same name.
    vim.lsp.config('jdtls', { cmd = function(dispatchers, config)
      local root = config.root_dir or vim.fn.getcwd()
      local workspace = vim.fn.stdpath('cache') .. '/jdtls/' .. vim.fn.sha256(root):sub(1, 16)
      local cmd = { 'jdtls', '-data', workspace }
      -- Prefer Homebrew's current JDK for the server; project JDKs stay independent.
      local candidates = {
        vim.env.JDTLS_JAVA_HOME and (vim.env.JDTLS_JAVA_HOME .. '/bin/java') or '',
        '/opt/homebrew/opt/openjdk/bin/java', '/usr/local/opt/openjdk/bin/java',
      }
      for _, java in ipairs(candidates) do
        if vim.fn.executable(java) == 1 then
          vim.list_extend(cmd, { '--java-executable', java })
          break
        end
      end
      return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root, env = config.cmd_env })
    end })
    -- Lint ordinary TS/JS projects even before an Oxlint config is added.
    vim.lsp.config('oxlint', { root_dir = function(bufnr, on_dir)
      local file = vim.api.nvim_buf_get_name(bufnr)
      on_dir(vim.fs.root(file, { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts', 'package.json', 'tsconfig.json', '.git' }) or vim.fs.dirname(file))
    end })
    -- Load the schema catalog only when a JSON/YAML server actually starts.
    vim.lsp.config('jsonls', {
      before_init = function(_, config)
        config.settings.json.schemas = require('schemastore').json.schemas()
      end,
      settings = { json = { validate = { enable = true } } },
    })
    vim.lsp.config('yamlls', {
      before_init = function(_, config)
        config.settings.yaml.schemas = require('schemastore').yaml.schemas()
      end,
      settings = { yaml = {
        schemaStore = { enable = false, url = '' },
        validate = true, customTags = { '!reference sequence' },
      } },
    })
    vim.lsp.config('sqls', { root_markers = { '.sqls.yml', 'package.json', 'pyproject.toml', '.git' } })
    vim.lsp.config('lua_ls', { settings = { Lua = {
      runtime = { version = 'LuaJIT' }, diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false }, telemetry = { enable = false },
    } } })
    local tools = require('toolchain')
    require('mason-lspconfig').setup({ automatic_enable = false })
    vim.lsp.enable(vim.tbl_keys(tools.servers))
    local missing_tools = false
    for _, name in ipairs(tools.packages()) do
      if vim.fn.filereadable(vim.fn.stdpath('data') .. '/mason/packages/' .. name .. '/mason-receipt.json') == 0 then
        missing_tools = true
        break
      end
    end
    require('mason-tool-installer').setup({
      ensure_installed = tools.packages(), auto_update = false,
      run_on_start = missing_tools and vim.env.DOTFILES_BOOTSTRAP ~= '1', start_delay = 1000,
      integrations = { ['mason-lspconfig'] = false },
    })
  end },
  { 'stevearc/conform.nvim', event = 'BufWritePre', cmd = 'ConformInfo', opts = {
    formatters_by_ft = {
      python = { 'ruff_format' }, lua = { 'stylua' },
      javascript = { 'prettier' }, javascriptreact = { 'prettier' },
      typescript = { 'prettier' }, typescriptreact = { 'prettier' },
      html = { 'prettier' }, css = { 'prettier' }, scss = { 'prettier' },
      json = { 'prettier' }, jsonc = { 'prettier' }, yaml = { 'prettier' },
      ['yaml.docker-compose'] = { 'prettier' }, less = { 'prettier' },
      markdown = { 'prettier' }, graphql = { 'prettier' },
      sh = { 'shfmt' }, bash = { 'shfmt' },
      -- SQL dialects differ: use sql-formatter explicitly with project options.
      -- SQL format-on-save is intentionally disabled below.
      sql = { 'sql_formatter' },
    },
    format_on_save = function(buf)
      if vim.g.disable_autoformat or vim.b[buf].disable_autoformat or vim.bo[buf].filetype == 'sql' then return end
      return { timeout_ms = 1500, lsp_format = 'fallback' }
    end,
  } },
  { 'nvim-treesitter/nvim-treesitter', branch = 'master', event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'TSInstall', 'TSInstallSync', 'TSUpdate', 'TSUpdateSync' }, build = ':TSUpdate', config = function()
    require('nvim-treesitter.configs').setup({
      ensure_installed = require('toolchain').parsers,
      highlight = { enable = true },
      incremental_selection = { enable = true, keymaps = { init_selection = '<C-Space>', node_incremental = '<C-Space>', node_decremental = '<BS>' } },
    })
  end },
}
