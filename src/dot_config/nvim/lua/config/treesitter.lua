-- Ensure nvim-treesitter is loaded before attempting configuration
local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  vim.notify('nvim-treesitter.configs not found!', vim.log.levels.ERROR)
  return
end

configs.setup {
  -- A list of parser names, or "all" (for latest version, use "all" or "maintained")
  ensure_installed = {
    -- Frontend
    "javascript", "typescript", "tsx", "html", "css", "json", "scss", "vue", "yaml",

    -- Backend
    "java", "php", "ruby", "python", "go", "rust",

    -- Shell/Config
    "bash", "fish", "lua", "vim", "vimdoc", "make", "dockerfile",

    -- Other
    "markdown", "markdown_inline", "regex", "query", "comment",
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    disable = {},

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  -- Indentation based on treesitter for the = operator.
  indent = {
    enable = true,
    disable = {},
  },

  -- Incremental selection
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
}
