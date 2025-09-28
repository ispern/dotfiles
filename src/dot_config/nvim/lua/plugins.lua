-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- theme
  use {
    'Mofiqul/dracula.nvim',
    config = [[require('config.dracula')]],
    after = { 'nvim-treesitter', 'nvim-cmp' }
  }

  -- Edit
  use {
    'windwp/nvim-ts-autotag',
    config = function() 
      require('nvim-ts-autotag').setup {}
    end
  }
  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup({
        disable_filetype = { "TelescopePrompt", "vim" }
      })
    end
  }
  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        toggler = {
          ---Line-comment toggle keymap
          line = '<C-_>',
        },
        opleader = {
          line = '<C-_>',
        },
      }
    end
  }
  use {
    'gaoDean/autolist.nvim',
    config = function()
      require('autolist').setup {}
    end,
    ft = { 'markdown' }
  }
  use { 'mattn/emmet-vim', ft = { 'html', 'erb', 'vue' } }

  -- Movement
  use 'chaoren/vim-wordmotion'
  use {
    {
      'ggandor/leap.nvim',
      requires = 'tpope/vim-repeat',
      config = [[require('leap').set_default_keymaps()]],
      disable = true
    },
    { 'ggandor/flit.nvim', config = [[require'flit'.setup { labeled_modes = 'nv' }]], disable = true },
  }

  -- Wrapping/delimiters
  use {
    'andymass/vim-matchup',
    setup = function()
      require('config.matchup')
    end,
    event = 'User ActuallyEditing'
  }
  use {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {}
    end
  }

  -- Search
  use {
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'telescope-fzf-native.nvim',
        'nvim-telescope/telescope-ui-select.nvim',
      },
      setup = [[require('config.telescope_setup')]],
      config = [[require('config.telescope')]],
      cmd = 'Telescope',
      module = 'telescope',
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      run = 'make',
    },
    'crispgm/telescope-heading.nvim',
    'nvim-telescope/telescope-file-browser.nvim',
  }

  -- Filer
  -- use 'justinmk/vim-dirvish'
  use {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    config = [[require('config.neo_tree')]],
    requires = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons', -- not strictly required, but recommended
      'MunifTanjim/nui.nvim',
    },
  }

  -- Buffer management
	use {
    'akinsho/bufferline.nvim',
    tag = "*",
    config = [[require('config.bufferline')]],
    requires = 'kyazdani42/nvim-web-devicons',
  }

  use {
    'nvim-lualine/lualine.nvim',
    config = [[require('config.lualine')]],
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
    after = 'dracula.nvim'
  }

  -- LSP
  use {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'neovim/nvim-lspconfig',
    'nvimtools/none-ls.nvim',
    'jay-babu/mason-null-ls.nvim'
  }

  -- Highlights
  use {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',  -- main is the recommended branch
    requires = {
      'RRethy/nvim-treesitter-textsubjects',
    },
    config = [[require('config.treesitter')]],
    run = ':TSUpdate',
  }
  use {
  'folke/trouble.nvim',
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  -- Snippets
  use {
    {
      'L3MON4D3/LuaSnip',
      tag = 'v1.*',
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },
    'rafamadriz/friendly-snippets',
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      'hrsh7th/cmp-nvim-lsp',
      'onsails/lspkind.nvim',
      { 'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
      { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      'lukas-reineke/cmp-under-comparator',
      { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    },
    config = [[require('config.cmp')]],
    after = 'LuaSnip',
  }

  -- Pretty UI
  use 'stevearc/dressing.nvim'
  use 'rcarriga/nvim-notify'
  use 'vigoux/notifier.nvim'
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  }
  use {
    'j-hui/fidget.nvim',
    config = function()
      require('fidget').setup {
        sources = {
          ['null-ls'] = { ignore = true },
        },
      }
    end,
  }
  use {
    'folke/zen-mode.nvim',
    config = function()
      require('zen-mode').setup()
    end
  }

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup {}
    end
  }
  use {
    'dinhhuy258/git.nvim',
    config = function()
      require('config.git')
    end
  }
  use {
    'TimUntersberger/neogit',
    requires = {
      'sindrets/diffview.nvim'
    },
    cmd = 'Neogit',
    config = [[require('config.neogit')]]
  }
  use 'github/copilot.vim'
  use {
    'pwntester/octo.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'kyazdani42/nvim-web-devicons',
    },
    config = function()
      require"octo".setup {}
    end,
    after = 'telescope.nvim'
  }

  -- Language
  use 'posva/vim-vue'
end)

