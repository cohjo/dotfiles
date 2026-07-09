local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require("mini.comment").setup()
      require("mini.pairs").setup()
      require("mini.surround").setup()
      require("mini.statusline").setup({ use_icons = false })
      require("mini.pick").setup()

      local map = vim.keymap.set
      map("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Find files" })
      map("n", "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Live grep" })
      map("n", "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Buffers" })
      map("n", "<leader>fh", "<cmd>Pick help<cr>", { desc = "Help" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "normal" },
      completion = {
        menu = { border = "single" },
        documentation = {
          auto_show = false,
          window = { border = "single" },
        },
      },
      signature = {
        enabled = true,
        window = { border = "single" },
      },
      sources = {
        default = { "lsp", "path", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    opts = {},
  },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
  install = { colorscheme = { "default" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "single",
    icons = {
      cmd = "",
      config = "",
      event = "",
      ft = "",
      init = "",
      keys = "",
      plugin = "",
      runtime = "",
      source = "",
      start = "",
      task = "",
      lazy = "",
    },
  },
})
