-- LSP configuration
-- Customize LSP servers and keymaps

return {
  -- Configure LSP servers
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
  -- Custom LSP keymaps
  keys = {
    -- These keymaps are already provided by LazyVim by default
    -- Custom keymaps can be added here if needed
    -- Example:
    -- { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },
  },
}

