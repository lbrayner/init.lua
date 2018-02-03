augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:MyVimGoodies#TabGoodies#lasttab = tabpagenr()
augroup END

command! TabEqualizeWindows call MyVimGoodies#TabGoodies#TabDo("normal! \<c-w>=")
