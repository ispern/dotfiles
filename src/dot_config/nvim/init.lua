local cmd = vim.cmd

require('base')

require('plugins')

-- local in_wsl = os.getenv('WSL_DISTRO_NAME') ~= nil
-- if in_wsl then
--   require('wsl')
-- end

-- Commands
local create_cmd = vim.api.nvim_create_user_command
create_cmd('PackerInstall', function()
  cmd [[packadd packer.nvim]]
  require('plugins').install()
end, {})
create_cmd('PackerUpdate', function()
  cmd [[packadd packer.nvim]]
  require('plugins').update()
end, {})
create_cmd('PackerSync', function()
  cmd [[packadd packer.nvim]]
  require('plugins').sync()
end, {})
create_cmd('PackerClean', function()
  cmd [[packadd packer.nvim]]
  require('plugins').clean()
end, {})
create_cmd('PackerCompile', function()
  cmd [[packadd packer.nvim]]
  require('plugins').compile()
end, {})


-- keymaps
local map = vim.api.nvim_set_keymap
local silent = { silent = true, noremap = true }
map('n', '<A-Left>', [[<cmd>bprevious<cr>]], silent)
map('n', '<A-Right>', [[<cmd>bnext<cr>]], silent)

