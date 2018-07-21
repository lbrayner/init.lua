augroup LastTabAutoGroup
    autocmd!
    au TabLeave * let g:tab#lasttab = tabpagenr()
augroup END

function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')

augroup TabActionsOnVimEnter
    autocmd!
    au VimEnter * call s:DoTabEqualizeWindows()
augroup END
