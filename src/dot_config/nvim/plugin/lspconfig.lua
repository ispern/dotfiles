require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    -- Frontend
    'eslint', 'emmet_ls', 'html', 'tsserver', 'cssls', 'cssmodules_ls', 'stylelint_lsp', 'volar', 'tailwindcss',

    -- Backend
    'jdtls', -- Java
    'psalm', -- PHP
    'solargraph', -- Ruby


    -- Script
    'sumneko_lua',  -- lua

    -- Database
    'sqlls',

    -- Infrastructure
    'terraformls',


    -- Other
    'marksman', 'jsonls', 'lemminx', 'yamlls',
  },
})
require('mason-lspconfig').setup_handlers({ function(server)
  require('lspconfig')[server].setup({})
end })

-- hover setting
local api = vim.api
local lsp = vim.lsp
local buf = lsp.buf

-- document highlight
api.nvim_create_autocmd("LspAttach", { callback = function(args)
  local bufnr = args.buf
  local client = lsp.get_client_by_id(args.data.client_id)
  if client.server_capabilities.document_highlight then
    local document_highlight_augroup_name = 'document-highlight'
    api.nvim_create_augroup(document_highlight_augroup_name, { clear = true })
    api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = document_highlight_augroup_name,
      callback = buf.document_highlight,
      buffer = bufnr,
    })

    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = document_highlight_augroup_name,
      callback = buf.clear_references,
      buffer = bufnr,
    })
  end
end })

-- diagnostic hover
vim.opt.updatetime = 500
local diagnostic_hover_augroup_name = 'lspconfig-diagnostic-hover'
api.nvim_create_augroup(diagnostic_hover_augroup_name, { clear = true })
api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, { group = diagnostic_hover_augroup_name, callback = function()
  if buf.server_ready() then
    vim.diagnostic.open_float()
  end
end })

-- disable virtual text
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false }
)

-- sign
local signs = { Error = " ", Warn = " ", Hint = "", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- lsp keymap
vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
