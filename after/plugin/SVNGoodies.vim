let s:leader = '\'

if exists("mapleader")
    let s:leader = mapleader
endif

if ! hasmapto(s:leader."D")
    nnoremap <silent> <leader>D :SVNDiffThis<cr>
endif
