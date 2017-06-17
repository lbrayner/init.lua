" let s:leader = '\'

" if exists("mapleader")
"     let s:leader = mapleader
" endif

" if ! hasmapto(s:leader."T")
"     nnoremap <leader>T :BufWipeTab<cr>
" endif

call MyVimGoodies#util#vimmap('nnoremap','<leader>T',':BufWipeTab<cr> ')
