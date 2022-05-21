function! s:DoTabEqualizeWindows()
    call tab#TabDo("res 1000 | normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')
command! Tabnew call util#PreserveViewPort("tabe ".fnameescape(expand("%")))
command! Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * call s:DoTabEqualizeWindows()
augroup END

map <Plug>GoToTab :call tab#GoToTab()<cr>
