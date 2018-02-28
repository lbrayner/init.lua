augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:MyVimGoodies#TabGoodies#lasttab = tabpagenr()
augroup END

command! TabEqualizeWindows call MyVimGoodies#TabGoodies#TabDo("normal! \<c-w>=")
command! -bang TabCloseRight call MyVimGoodies#TabGoodies#TabCloseRight('<bang>')
command! -bang TabCloseLeft call MyVimGoodies#TabGoodies#TabCloseLeft('<bang>')
