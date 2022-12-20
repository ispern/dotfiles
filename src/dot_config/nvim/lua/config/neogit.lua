require('neogit').setup {
  disable_commit_confirmation = true,
  disable_signs = true,
  integrations = {
    diffview = true
  }
}


local map = vim.api.nvim_set_keymap

map('n', '<a-5>', [[<cmd>Neogit<cr>]], { silent = true, noremap = true })

