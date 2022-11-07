function! s:DoTabEqualizeWindows()
    call tab#TabDo("normal! \<c-w>=")
endfunction

command! -nargs=0 TabEqualizeWindows call s:DoTabEqualizeWindows()
command! -nargs=0 -bang TabcloseRight call tab#TabcloseRight("<bang>")
command! -nargs=0 -bang TabcloseLeft call tab#TabcloseLeft("<bang>")
command! -nargs=0 -bang Tabonly call tab#Tabonly("<bang>")
command! -nargs=0 -bang Tabclose call tab#Tabclose("<bang>")
command! -nargs=0 -bang -range TabcloseRange call tab#TabcloseRange("<bang>")
command! -nargs=0 Tabnew call util#PreserveViewPort("tabe ".fnameescape(expand("%")))
command! -nargs=0 Tabedit Tabnew

augroup TabActionsOnVimEnter
    autocmd!
    autocmd VimEnter * if v:this_session != "" | call s:DoTabEqualizeWindows() | endif
augroup END

map <Plug>GoToTab :call tab#GoToTab()<cr>
