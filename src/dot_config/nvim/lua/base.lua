local g = vim.g

-- Leader
g.mapleader = ' '
g.maplocalleader = ','

-- Settings
local opt = vim.opt
opt.shellslash = true
opt.textwidth = 0
opt.scrolloff = 7
opt.swapfile = false
opt.whichwrap:append '<,>,h,l'
opt.lazyredraw = true
opt.showmatch = true
opt.ignorecase = true
opt.smartcase = true
opt.tabstop = 2
opt.softtabstop = 0
opt.expandtab = true
opt.shiftwidth = 2
opt.number = true
opt.smartindent = true
opt.laststatus = 3
opt.showmode = false
opt.shada = [['20,<50,s10,h,/100]]
opt.hidden = true
opt.shortmess:append 'c'
opt.joinspaces = false
opt.guicursor = [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]]
opt.updatetime = 100
opt.conceallevel = 2
opt.concealcursor = 'nc'
opt.previewheight = 5
opt.undofile = true
opt.synmaxcol = 500
opt.display = 'msgsep'
opt.cursorline = true
opt.modeline = false
opt.mouse = 'nivh'
opt.signcolumn = 'yes:1'
opt.clipboard = 'unnamedplus'
opt.termguicolors = true
opt.conceallevel = 0

vim.cmd [[
if has('clipboard') || exists('g:vscode')
    let s:clip = '/mnt/c/Windows/System32/clip.exe'
    if executable(s:clip)
        augroup WSLYank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
        augroup END
    endif
endif
]]

