local map = vim.api.nvim_set_keymap

local silent = { silent = true, noremap = true }

-- Navigate buffers and repos
map('n', '<c-e>', [[<cmd>Telescope buffers show_all_buffers=true theme=get_dropdown<cr>]], silent)
map('n', '<c-p>', [[<cmd>Telescope commands theme=get_dropdown<cr>]], silent)
map('n', '<c-s>', [[<cmd>Telescope git_files theme=get_dropdown<cr>]], silent)
map('n', '<c-o>', [[<cmd>Telescope find_files theme=get_dropdown hidden=true<cr>]], silent)
map('n', '<c-s-F>', [[<cmd>Telescope live_grep theme=get_dropdown hidden=true<cr>]], silent)
map('n', '<a-2>', [[<cmd>Telescope file_browser hidden=true<cr>]], silent)
