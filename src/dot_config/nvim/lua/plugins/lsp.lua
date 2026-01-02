-- LSP plugin configuration
-- Override LazyVim's default LSP settings

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Frontend
        eslint = {},
        emmet_ls = {},
        html = {},
        tsserver = {},
        cssls = {},
        cssmodules_ls = {},
        stylelint_lsp = {},
        volar = {},
        tailwindcss = {},

        -- Database
        sqlls = {},

        -- Infrastructure
        terraformls = {},

        -- Other
        marksman = {},
        jsonls = {},
        lemminx = {},
        yamlls = {},
      },
    },
  },
}

