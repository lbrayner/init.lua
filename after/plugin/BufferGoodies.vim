let s:leader = '\'

if exists("mapleader")
    let s:leader = mapleader
endif

if ! hasmapto(s:leader."T")
    nnoremap <leader>T :BufWipeTab<cr>
endif
