-- Custom keymaps
-- This file contains custom keymaps that override or extend LazyVim defaults

return {
  n = {
    -- Buffer navigation (Alt+Arrow keys)
    ["<A-Left>"] = { "<cmd>bprevious<cr>", desc = "Previous buffer" },
    ["<A-Right>"] = { "<cmd>bnext<cr>", desc = "Next buffer" },
  },
}

