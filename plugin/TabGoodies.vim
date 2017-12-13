augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:MyVimGoodies#TabGoodies#lasttab = tabpagenr()
augroup END
