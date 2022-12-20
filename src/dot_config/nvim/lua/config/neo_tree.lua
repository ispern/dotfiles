local map = vim.api.nvim_set_keymap

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("neo-tree").setup({
    filesystem = {
        filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        },
    },
    window = {
      mappings = {
        ["<space>"] = { 
          "toggle_node", 
          nowait = true, -- disable `nowait` if you have existing combos starting with this char that you want to use 
        }
      }

    }
})

map('n', '<a-1>', ':Neotree toggle<cr>', {noremap = true})
