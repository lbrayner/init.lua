function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<c-w>=")
endfunction

command! -nargs=0 TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -nargs=0 -bang TabCloseRight call tab#TabCloseRight('<bang>')
command! -nargs=0 -bang TabCloseLeft call tab#TabCloseLeft('<bang>')
command! -nargs=0 -bang TabOnly call tab#TabOnly('<bang>')
command! -nargs=0 Tabnew call util#PreserveViewPort("tabe ".fnameescape(expand("%")))
command! -nargs=0 Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * if v:this_session != "" | call s:DoTabEqualizeWindows() | endif
augroup END

map <Plug>GoToTab :call tab#GoToTab()<cr>
