function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<c-w>=")
endfunction

command! TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -bang TabCloseLeft call tab#TabCloseLeft('<bang>')
command! Tabnew call util#PreserveViewPort("tabe ".fnameescape(expand("%")))
command! Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * if v:this_session != "" | call s:DoTabEqualizeWindows() | endif
augroup END

map <Plug>GoToTab :call tab#GoToTab()<cr>
