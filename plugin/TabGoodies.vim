augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:TabGoodies#lasttab = tabpagenr()
augroup END

function! s:DoTabEqualizeWindows()
    call TabGoodies#TabDo("normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call TabGoodies#TabCloseRight('<bang>')
command! -bang TabCloseLeft call TabGoodies#TabCloseLeft('<bang>')

augroup TabActionsOnVimEnter
    autocmd!
    au VimEnter * call s:DoTabEqualizeWindows()
augroup END
