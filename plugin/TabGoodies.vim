augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:MyVimGoodies#TabGoodies#lasttab = tabpagenr()
augroup END

function! s:DoTabEqualizeWindows()
    call MyVimGoodies#TabGoodies#TabDo("normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call MyVimGoodies#TabGoodies#TabCloseRight('<bang>')
command! -bang TabCloseLeft call MyVimGoodies#TabGoodies#TabCloseLeft('<bang>')

augroup TabActionsOnVimEnter
    autocmd!
    au VimEnter * call s:DoTabEqualizeWindows()
augroup END
