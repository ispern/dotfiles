" Only do this when not done yet for this buffer
if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal dictionary=~/.vim/dict/javascript.dict
set tags=~/Dropbox/Sync/dotted/tags-extjs-3.3.0,~/Dropbox/Sync/dotted/tags-sencha-touch-1.0.1
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
compiler javascriptlint
set tags=~/.vim/tags/extjs-tags,~/.vim/tags/sencha-touch-tags

" javascript fold(Anonymous function)
syntax match   javaScriptAnonymouseFunction       /\<function\>/ nextgroup=javaScriptAnonymouseFuncName skipwhite                
syntax region  javaScriptAnonymouseFuncName       contained matchgroup=javaScriptAnonymouseFuncName start=/(/ end=/)/ contains=javaScriptLineComment,javaScriptComment nextgroup=javaScriptFuncBlock skipwhite skipempty
syntax region  javaScriptAnonymouseFuncBlock      contained matchgroup=javaScriptAnonymouseFuncBlock start="{" end="}" contains=@javaScriptAll,javaScriptParensErrA,javaScriptParensErrB,javaScriptParen,javaScriptBracket,javaScriptBlock fold
syntax keyword javaScriptAnonymouseFunction function

