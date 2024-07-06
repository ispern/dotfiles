local cmd = vim.cmd

require('base')

require('plugins')

-- keymaps
local map = vim.api.nvim_set_keymap
local silent = { silent = true, noremap = true }
map('n', '<A-Left>', [[<cmd>bprevious<cr>]], silent)
map('n', '<A-Right>', [[<cmd>bnext<cr>]], silent)

